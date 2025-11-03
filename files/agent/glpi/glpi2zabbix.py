#!/usr/bin/python3
import argparse
import logging
import logging.handlers
import random
import re
import string
import sys

import requests
from pyzabbix import ZabbixAPI, ZabbixAPIException


class GLPIException(Exception):
    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return 'GLPI: ' + str(self.msg)


class ZabbixException(Exception):
    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return f"Zabbix: {str(self.msg)}"


class WarningException(Exception):
    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return f"WARNING: {str(self.msg)}"


def logger_setup():
    logger = logging.getLogger('glpi2zabbix')
    logger.setLevel(logging.INFO)

    # setting up logging to file
    logfile = logging.handlers.SysLogHandler(address='/dev/log')
    logfile.setLevel(logging.INFO)
    logfile.setFormatter(
        logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
    )

    logger.addHandler(logfile)

    return logger


def strip_trailing_slash(url):
    if url[-1] == '/':
        url = url[:-1]

    return url


def generate_random_alphanum_string(n):
    s = ''.join(
        (random.choice(string.ascii_lowercase + string.digits)
         for i in range(n))
    )
    return str(s)


class GLPI:
    def __init__(self, url, app_token, user_token):
        self.url = url
        self.app_token = app_token
        self.user_token = user_token
        self.headers = {
            "Content-Type": "application/json",
            "Session-Token": "",
            "App-Token": self.app_token
        }
        self.params = {"range": "0-10000"}
        self.all_users = None
        self.groups = None
        self.usergroups = None
        self.computertypes = None
        self.hosts = None

    def login(self):
        try:
            response = requests.get(
                f"{self.url}/initSession",
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"user_token {self.user_token}",
                    "App-Token": self.app_token
                },
                params={"user_token": self.user_token}
            )

            response.raise_for_status()

            self.headers.update({
                "Session-Token": response.json()["session_token"]
            })

        except (
                requests.exceptions.HTTPError,
                requests.exceptions.ConnectionError,
                requests.exceptions.RequestException,
                requests.exceptions.Timeout,
                requests.exceptions.TooManyRedirects
        ) as e:
            raise GLPIException(msg=f"Error during login: {str(e)}")

    def logout(self):
        try:
            response = requests.get(
                f"{self.url}/killSession", headers=self.headers
            )

            response.raise_for_status()

        except (
                requests.exceptions.HTTPError,
                requests.exceptions.ConnectionError,
                requests.exceptions.RequestException,
                requests.exceptions.Timeout,
                requests.exceptions.TooManyRedirects
        ) as e:
            raise GLPIException(msg=f"Error during logout: {str(e)}")

    def get_users(self):
        """
        Get all the users with '@srce.hr' from GLPI.
        :return: list of users with '@srce.hr' in name
        """
        try:
            response = requests.get(
                f"{self.url}/User", headers=self.headers, params=self.params
            )
            response.raise_for_status()

            users = response.json()

            srce_users = [d for d in users if 'srce.hr' in d['name']]

            self.all_users = srce_users

            return srce_users

        except (
                requests.exceptions.HTTPError,
                requests.exceptions.ConnectionError,
                requests.exceptions.RequestException,
                requests.exceptions.Timeout,
                requests.exceptions.TooManyRedirects
        ) as e:
            raise GLPIException(msg=f"Error fetching users: {str(e)}")

    def _get_groups(self):
        """
        Get groups from GLPI.
        :return: list of all groups in GLPI.
        """
        try:
            response = requests.get(
                f"{self.url}/Group", headers=self.headers, params=self.params
            )
            response.raise_for_status()

            return response.json()

        except (
                requests.exceptions.HTTPError,
                requests.exceptions.ConnectionError,
                requests.exceptions.RequestException,
                requests.exceptions.Timeout,
                requests.exceptions.TooManyRedirects
        ) as e:
            raise GLPIException(msg=f"Error fetching groups: {str(e)}")

    def _get_computertypes(self):
        """
        :return: list of computer types as defined in GLPI.
        """
        try:
            response = requests.get(
                f"{self.url}/ComputerType",
                headers=self.headers, params=self.params

            )
            response.raise_for_status()

            return response.json()

        except (
                requests.exceptions.HTTPError,
                requests.exceptions.ConnectionError,
                requests.exceptions.RequestException,
                requests.exceptions.Timeout,
                requests.exceptions.TooManyRedirects
        ) as e:
            raise GLPIException(msg=f"Error fetching computer types: {str(e)}")

    def get_computertypes(self):
        return [t['name'] for t in self._get_computertypes()]

    def _get_usergroups(self):
        if not self.all_users:
            self.get_users()

        usergroups = dict()
        for user in self.all_users:
            try:
                response = requests.get(
                    f"{self.url}/User/{user['id']}/Group_User",
                    headers=self.headers, params=self.params
                )
                response.raise_for_status()

                usergroups.update({user["name"]: response.json()})

            except (
                    requests.exceptions.HTTPError,
                    requests.exceptions.ConnectionError,
                    requests.exceptions.RequestException,
                    requests.exceptions.Timeout,
                    requests.exceptions.TooManyRedirects
            ) as e:
                raise GLPIException(
                    f"Error fetching groups for user {user['name']}: {str(e)}"
                )

        return usergroups

    def get_usergroups(self):
        if not self.groups:
            self.groups = self._get_groups()

        if not self.usergroups:
            self.usergroups = self._get_usergroups()

        groups_ids = [
            item["groups_id"] for item in list(self.usergroups.values())[0]
        ]

        return sorted([
            group["name"] for group in self.groups if group["id"] in groups_ids
        ])

    def get_users_usergroups(self):
        if not self.groups:
            self.groups = self._get_groups()

        if not self.usergroups:
            self.usergroups = self._get_usergroups()

        usergroups = dict()
        for user, group_data in self.usergroups.items():
            groups_ids = [item["groups_id"] for item in group_data]

            usergroups.update({
                user: [
                    group["name"] for group in self.groups if
                    group["id"] in groups_ids
                ]
            })

        return usergroups

    @staticmethod
    def _get_name_from_key(i, items):
        try:
            name = [
                t["name"] for t in items if t["id"] != 0 and t["id"] == i
            ]

            if len(name) > 0:
                return name[0]
            else:
                return ""

        except KeyError:
            return ""

    def get_hosts(self, zabbix_host):
        if not self.computertypes:
            self.computertypes = self._get_computertypes()

        if not self.groups:
            self.groups = self._get_groups()

        try:
            response = requests.get(
                f"{self.url}/Computer", headers=self.headers, params=self.params
            )
            response.raise_for_status()

            zabbix_host_names = [host["name"] for host in zabbix_host]

            computers = response.json()

            for computer in computers:
                computer.update({
                    "computertypes_name": self._get_name_from_key(
                        i=computer["computertypes_id"], items=self.computertypes
                    ),
                    "groups_name": self._get_name_from_key(
                        i=computer["groups_id"], items=self.groups
                    ),
                    "groups_name_tech": self._get_name_from_key(
                        i=computer["groups_id_tech"], items=self.groups
                    )
                })

            return [
                computer for computer in computers if
                computer["name"] in zabbix_host_names
            ]

        except (
                requests.exceptions.HTTPError,
                requests.exceptions.ConnectionError,
                requests.exceptions.RequestException,
                requests.exceptions.Timeout,
                requests.exceptions.TooManyRedirects
        ) as e:
            raise GLPIException(msg=f"Error fetching computers: {str(e)}")

    def get_hostgroups(self, zabbix_host):
        """
        Get hosts from GLPI which exist on Zabbix and their host groups.
        :param zabbix_host: list of host's names in Zabbix.
        :return: list of unique host groups
        """
        if not self.hosts:
            self.hosts = self.get_hosts(zabbix_host=zabbix_host)

        hostgroups = set()
        for host in self.hosts:
            for key in [
                "computertypes_name", "groups_name", "groups_name_tech"
            ]:
                if key in host.keys() and host[key] != "":
                    hostgroups.add(host[key])

        return sorted(list(hostgroups))


class Zabbix:
    def __init__(self, url, username, password, logger):
        self.url = strip_trailing_slash(url)
        self.username = username
        self.password = password
        self.logger = logger
        self.server = None
        self.users = None
        self.usergroups = None
        self.guestid = None
        self.hosts = None
        self.hostgroups = None
        self.new_hostgroups = None

    def _get_initial_data(self):
        """
        Get initial data from Zabbix: users, user groups, id of 'Guests' user
        group, hosts, and host groups.
        :return:
        """
        self.users = self._get_users()
        self.usergroups = self._get_usergroups()
        self.guestid = [
            d.get('usrgrpid') for d in self.usergroups
            if d.get('name') == 'Guests'
        ][0]
        self.hostgroups = self._get_hostgroups()
        self.hosts = self._get_hosts()

    def login(self):
        try:
            self.server = ZabbixAPI(self.url)
            self.server.login(self.username, self.password)

        except ZabbixAPIException as e:
            raise ZabbixException(msg=f"Error during login: {str(e)}")

        else:
            try:
                self._get_initial_data()

            except ZabbixException as e:
                self.logout()
                raise ZabbixException(msg=str(e))

    def logout(self):
        try:
            self.server.user.logout()

        except ZabbixAPIException as e:
            raise ZabbixException(msg=f"Error during logout: {str(e)}")

    def _get_hosts(self):
        try:
            return self.server.host.get()

        except ZabbixAPIException as e:
            raise ZabbixException(msg='Error fetching hosts: ' + str(e))

    def _get_hostgroups(self):
        try:
            return self.server.hostgroup.get()

        except ZabbixAPIException as e:
            raise ZabbixException(msg='Error fetching host groups: ' + str(e))

    def _get_users(self):
        try:
            return self.server.user.get(output='extend')

        except ZabbixAPIException as e:
            raise ZabbixException(msg=f"Error fetching users: {str(e)}")

    def _get_usergroups(self):
        try:
            return self.server.usergroup.get(selectRights=1)

        except ZabbixAPIException as e:
            raise ZabbixException(msg=f"Error fetching user groups: {str(e)}")

    def create_hostgroups(self, glpi_hostgroups):
        """
        Creating hostgroups for hosts existing on Zabbix.
        :param glpi_hostgroups: list of unique host groups' names from GLPI
        """
        new_hostgroup = list()
        skipped_hostgroup = list()
        for item in glpi_hostgroups:
            # if it does not exist, create it
            if not any(
                    d.get('name', None) == item for d in self.hostgroups
            ):
                try:
                    self.server.hostgroup.create(name=item)
                    new_hostgroup.append(item)

                except ZabbixAPIException as e:
                    self.logger.warning(
                        f"Zabbix: Host group {item} not created: {str(e)}"
                    )
                    skipped_hostgroup.append(item)
                    continue

        if len(skipped_hostgroup) > 0:
            raise ZabbixException(
                f"Host group(s) {', '.join(skipped_hostgroup)} not created"
            )

        else:
            self.new_hostgroups = new_hostgroup

    def update_hosts_groups(self, glpi_hosts, glpi_computertypes):
        """
        Update hosts with host groups according to GLPI data.
        :param glpi_hosts: list detailed hosts from GLPI
        :param glpi_computertypes: list of computer types as defined in GLPI
        """
        glpi_group_pattern = re.compile('\d{3}-\d{2}-\d{3}')
        for item in glpi_hosts:
            try:
                zabbix_host_id = [
                    d.get('hostid') for d in self.hosts
                    if d.get('name') == item['name']
                ][0]
                #Check host flags → skip if discovered (flags = 4)
                try:
                    zabbix_host_info = self.server.host.get(
                    hostids=zabbix_host_id,
                    output=["flags"]
                )[0]
                except ZabbixAPIException as e:
                    self.logger.warning(
                        f"Zabbix: Skipping host {item['name']}: unable to read host flags: {str(e)}"
                )
                    continue

                if int(zabbix_host_info.get("flags", 0)) == 4:
                    self.logger.info(
                        f"Zabbix: Skipping host {item['name']} because it is discovered (flags = 4)"
                )
                    continue
                    
                glpi_hostgroup = set()
                if 'groups_name' in item.keys():
                    glpi_hostgroup.add(item['groups_name'])

                if 'groups_name_tech' in item.keys():
                    glpi_hostgroup.add(item['groups_name_tech'])

                if 'computertypes_name' in item.keys():
                    glpi_hostgroup.add(item['computertypes_name'])

                if not glpi_hostgroup:
                    continue

                else:
                    try:
                        zabbix_hostgroup_with_host = self.server.hostgroup.get(
                            hostids=zabbix_host_id
                        )

                    except ZabbixAPIException as e:
                        self.logger.warning(
                            f"Zabbix: Skipping host {item['name']}: "
                            f"Unable to fetch its host groups: {str(e)}"
                        )
                        continue

                    else:
                        zabbix_hostgroup_names = set(
                            item['name'] for item in zabbix_hostgroup_with_host
                        )

                        update = list(
                            glpi_hostgroup.union(zabbix_hostgroup_names)
                        )
                        if update != zabbix_hostgroup_names:
                            zabbix_hostgroup_update = list()
                            for i in update:
                                # skip computer types and groups named after
                                # services (pattern above) which are not in
                                # glpi_hostgroup
                                if i in glpi_computertypes and i not in \
                                        glpi_hostgroup \
                                        or re.match(glpi_group_pattern, i) \
                                        and i not in glpi_hostgroup:
                                    pass

                                else:
                                    x2 = [
                                        d.get('groupid') for d in
                                        self.hostgroups
                                        if d.get('name') == i
                                    ]
                                    if x2:
                                        zabbix_hostgroup_update.append(
                                            {'groupid': int(x2[0])}
                                        )

                            self.server.host.update(
                                hostid=zabbix_host_id,
                                groups=sorted(
                                    zabbix_hostgroup_update,
                                    key=lambda k: k["groupid"]
                                )
                            )

            except IndexError:
                self.logger.warning(
                    f"Zabbix: Host {item['name']} not updated: "
                    f"Host not registered in Zabbix"
                )
                continue

            except ZabbixAPIException as e:
                self.logger.warning(
                    f"Zabbix: Unable to update host {item['name']}: {str(e)}"
                )

    def remove_empty_hostgroups(self):
        """
        Remove host groups which are left empty.
        """
        try:
            hostgroups_with_hosts = self.server.hostgroup.get(with_hosts=True)

        except ZabbixAPIException as e:
            self.logger.warning(
                f"Zabbix: Unable to determine empty host groups: {str(e)}"
            )

        else:
            # some groups SHOULD NOT be deleted
            not_deletable = \
                ['Templates', 'Hypervisors', 'Virtual machines'] + \
                [
                    g.get('name') for g in self.hostgroups
                    if re.search('template', g.get('name'), re.IGNORECASE)
                ] + \
                [
                    g.get("name") for g in self.hostgroups if
                    g.get("internal") == "1"
                ]
            hostgroups_with_hosts = hostgroups_with_hosts + [
                g for g in self.hostgroups if g.get('name') in not_deletable
            ]

            empty_hostgroups = [
                eg for eg in self.hostgroups if eg not in hostgroups_with_hosts
            ]

            if empty_hostgroups:
                for item in empty_hostgroups:
                    try:
                        self.server.hostgroup.delete(int(item['groupid']))

                    except ZabbixAPIException as e:
                        self.logger.warning(
                            f"Zabbix: Unable to delete host group "
                            f"{item['name']}: {str(e)}"
                        )
                        continue

    def update_usergroups(self):
        """
        If there has been new host groups created, update user groups with
        appropriate permissions.
        """
        try:
            # update host groups
            self.hostgroups = self._get_hostgroups()

        except ZabbixException as e:
            self.logger.warning("User groups not updated")
            raise ZabbixException(
                f"Unable to fetch updated host groups: {str(e)[44:]}"
            )

        else:
            if self.new_hostgroups:
                # Updating user groups with the same name as newly created host
                # group (if it exists)
                for item in self.new_hostgroups:
                    usrid = [
                        d.get('usrgrpid') for d in self.usergroups
                        if d.get('name') == item
                    ]
                    grpid = [
                        d.get('groupid') for d in self.hostgroups
                        if d.get('name') == item
                    ]
                    if usrid:
                        try:
                            self.server.usergroup.update(
                                usrgrpid=usrid[0],
                                rights={'permission': 3, 'id': grpid[0]}
                            )

                        except ZabbixAPIException as e:
                            self.logger.warning(
                                f"Zabbix: Error updating user group "
                                f"{item}: {str(e)}"
                            )
                            continue

            # Checking if 'Guest' user group needs updating
            guestrights = [
                d.get('rights') for d in self.usergroups
                if d.get('name') == 'Guests'
            ][0]

            guestgroupid = [d.get('id') for d in guestrights]
            hostgroupids = [d.get('groupid') for d in self.hostgroups]

            if guestgroupid != hostgroupids:
                guest_rights = list()
                for hstgrpid in hostgroupids:
                    guest_rights.append({'permission': 2, 'id': hstgrpid})

                self.server.usergroup.update(
                    usrgrpid=self.guestid, rights=guest_rights
                )

    def create_usergroups(self, glpi_usergroups):
        """
        Creating user groups if they do not exist in Zabbix. If the host group
        with the same name exists, assign appropriate permission to newly
        created user group.
        :param glpi_usergroups: unique user groups from GLPI
        """
        for item in glpi_usergroups:
            if not any(
                    d.get('name', None) == item for d in self.usergroups
            ):
                hostgrpid = [
                    d.get('groupid') for d in self.hostgroups
                    if d.get('name') == item
                ]
                try:
                    if hostgrpid:
                        self.server.usergroup.create(
                            name=item,
                            rights={"permission": 3, "id": hostgrpid[0]}
                        )
                    else:
                        self.server.usergroup.create(name=item)

                except ZabbixAPIException as e:
                    self.logger.warning(
                        f"Zabbix: Unable to create user group {item}: {str(e)}"
                    )
                    continue

    def handle_users(self, glpi_users, glpi_users_with_groups):
        """
        If user from GLPI does not exist in Zabbix, create him/her. If it
        exists, check if his/her name or surname have been changed. If they have
        been changed, update them. Then delete the users from Zabbix which do
        not exist in GLPI, and make sure that default Zabbix users are not
        deleted.
        :param glpi_users: Users from GLPI.
        :param glpi_users_with_groups: dict which contains users' names and the
        groups they are assigned to.
        """
        for key, value in glpi_users_with_groups.items():
            if not any(d.get('username', None) == key for d in self.users):
                name = [
                    d.get('firstname') for d in glpi_users
                    if key == d.get('name')
                ]

                if name:
                    name = name[0]

                else:
                    name = ''

                surname = [
                    d.get('realname') for d in glpi_users
                    if key == d.get('name')
                ]

                if surname:
                    surname = surname[0]

                else:
                    surname = ''

                grpid = list()
                for item in value:
                    x = [
                        d.get('usrgrpid') for d in self.usergroups
                        if item == d.get('name')
                    ]
                    if x:
                        grpid.append({'usrgrpid': int(x[0])})

                # all the users are members of 'Guests' usergroup
                grpid.append({'usrgrpid': int(self.guestid)})

                if len(grpid) == 1:
                    usertype = 1    # Zabbix user

                else:
                    usertype = 2    # Zabbix admin

                try:
                    self.server.user.create(
                        username=key,
                        passwd=generate_random_alphanum_string(30),
                        usrgrps=sorted(grpid, key=lambda k: k["usrgrpid"]),
                        name=name, surname=surname, roleid=usertype
                    )

                except ZabbixAPIException as e:
                    self.logger.warning(
                        f"Zabbix: Unable to create user {key}: {str(e)}"
                    )
                    continue

            else:
                usrid = [
                    d.get('userid') for d in self.users if
                    key == d.get('username')
                ][0]

                # Check if name and surname are equal in GLPI and Zabbix:
                glpi_name = [
                    d.get('firstname') for d in glpi_users
                    if key == d.get('name')
                ]

                if glpi_name:
                    glpi_name = glpi_name[0]

                zabbix_name = [
                    d.get('name') for d in self.users
                    if key == d.get('username')
                ][0]

                if glpi_name != zabbix_name:
                    try:
                        self.server.user.update(userid=usrid, name=glpi_name)

                    except ZabbixAPIException as e:
                        self.logger.warning(
                            f"Zabbix: Unable to update name of user {key}: "
                            f"{str(e)}"
                        )

                glpi_surname = [
                    d.get('realname') for d in glpi_users
                    if key == d.get('name')
                ]

                if glpi_surname:
                    glpi_surname = glpi_surname[0]
                zabbix_surname = [
                    d.get('surname') for d in self.users
                    if key == d.get('username')
                ][0]
                if glpi_surname != zabbix_surname:
                    try:
                        self.server.user.update(
                            userid=usrid, surname=glpi_surname
                        )

                    except ZabbixAPIException as e:
                        self.logger.warning(
                            f"Zabbix: Unable to update surname of user {key}: "
                            f"{str(e)}"
                        )

                try:
                    usrgrp = self.server.usergroup.get(userids=usrid)

                except ZabbixAPIException as e:
                    self.logger.warning(
                        f"Zabbix: Unable to fetch user groups of user {key}: "
                        f"{str(e)}"
                    )
                    self.logger.warning(
                        f"Skipping user group analysis for user {key}"
                    )

                else:
                    usrgrpset = set()
                    for i in usrgrp:
                        usrgrpset.add(i['name'])
                    if not value:
                        value = ['Guests']

                    if not set(value).issubset(usrgrpset):
                        usrgrplist = list(set(value).union(usrgrpset))
                        usrgrpids = list()
                        for item in usrgrplist:
                            x1 = [
                                d.get('usrgrpid') for d in self.usergroups
                                if d.get('name') == item
                            ]
                            if x1:
                                usrgrpids.append({'usrgrpid': int(x1[0])})

                        usrtype = [
                            d.get('roleid') for d in self.users
                            if d.get('username') == key
                        ][0]
                        try:
                            if usrtype == "3":
                                self.server.user.update(
                                    userid=usrid,
                                    usrgrps=sorted(
                                        usrgrpids, key=lambda k: [k["usrgrpid"]]
                                    ),
                                    passwd=generate_random_alphanum_string(30)
                                )
                            else:
                                if len(usrgrplist) > 1:
                                    self.server.user.update(
                                        userid=usrid,
                                        usrgrps=sorted(
                                            usrgrpids,
                                            key=lambda k: k["usrgrpid"]
                                        ),
                                        roleid=2,
                                        passwd=generate_random_alphanum_string(
                                            30
                                        )
                                    )
                                else:
                                    self.server.user.update(
                                        userid=usrid,
                                        usrgrps=sorted(
                                            usrgrpids,
                                            key=lambda k: k["usrgrpid"]
                                        ),
                                        roleid=1,
                                        passwd=generate_random_alphanum_string(
                                            30
                                        )
                                    )

                        except ZabbixAPIException as e:
                            self.logger.warning(
                                f"Zabbix: Unable to update user groups of user "
                                f"{key}: {str(e)}"
                            )

        # Default Zabbix users
        defaultusersalias = ['guest', 'apiuser', 'nagios', 'Admin']
        default_users = [
            d for d in self.users if d.get('username') in defaultusersalias
        ]
        superadmin = [d for d in self.users if d.get('type') == '3']
        default_users = default_users + superadmin

        # Remove users from Zabbix which don't exist on GLPI (except the
        # default ones)
        for item in self.users:
            if not any(
                    d.get('name', None) == item['username'] for d in
                    glpi_users
            ) and item not in default_users:
                try:
                    self.server.user.delete(item['userid'])

                except ZabbixAPIException as e:
                    self.logger.warning(
                        f"Zabbix: User {item['username']} not deleted: {str(e)}"
                    )
                    continue

    def delete_usergroups(self):
        """
        Remove empty user groups, except for the default ones.
        """
        # Returns the users from the user group in the users property.
        try:
            usergroups = self.server.usergroup.get(selectUsers=1)

        except ZabbixAPIException as e:
            self.logger.warning(f"Zabbix: Error fetching user groups: {str(e)}")
            self.logger.warning("Skipping deletion of user groups")

        else:
            # Default Zabbix usergroups
            default_usergroup_name = [
                'Guests', 'API', 'Debug', 'Disabled',
                'No access to the frontend'
            ]
            default_usergroups = [
                d for d in usergroups if d.get('name') in default_usergroup_name
            ]

            # If user group is empty, remove it
            for item in usergroups:
                if not item['users'] and item not in default_usergroups:
                    try:
                        self.server.usergroup.delete(item['usrgrpid'])

                    except ZabbixAPIException as e:
                        self.logger.warning(
                            f"Zabbix: Error deleting user group "
                            f"{item['name']}: {str(e)}"
                        )


def main():
    logger = logger_setup()

    logger.info('Processing started')

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--glpi_url', dest='glpi_url', help='GLPI url', type=str, required=True
    )
    parser.add_argument(
        '--glpi_apptoken', dest='glpi_apptoken', help='GLPI apptoken', type=str,
        required=True
    )
    parser.add_argument(
        '--glpi_usertoken', dest='glpi_usertoken', help='GLPI usertoken',
        type=str, required=True
    )
    parser.add_argument(
        '--zabbix_url', dest='zabbix_url', help='Zabbix url', type=str,
        required=True
    )
    parser.add_argument(
        '--zabbix_username', dest='zabbix_username', help='Zabbix username',
        type=str, required=True
    )
    parser.add_argument(
        '--zabbix_password', dest='zabbix_password', help='Zabbix password',
        type=str, required=True
    )

    args = parser.parse_args()
    glpi_url = args.glpi_url
    glpi_apptoken = args.glpi_apptoken
    glpi_usertoken = args.glpi_usertoken
    zabbix_url = args.zabbix_url
    zabbix_username = args.zabbix_username
    zabbix_password = args.zabbix_password

    # Initializing GLPI and Zabbix classes
    glpi = GLPI(
        url=glpi_url,
        app_token=glpi_apptoken,
        user_token=glpi_usertoken
    )

    zabbix = Zabbix(
        url=zabbix_url,
        username=zabbix_username,
        password=zabbix_password,
        logger=logger
    )

    try:
        logger.info("Logging into GLPI API")
        glpi.login()
        logger.info("Logging into Zabbix API")
        zabbix.login()

    except GLPIException as e:
        logger.error(f"GLPI logging error: {str(e)}")
        sys.exit(1)

    except ZabbixAPIException as e:
        logger.error(f"Zabbix logging error: {str(e)}")
        sys.exit(1)

    try:
        logger.info('Fetching GLPI data')
        glpi_users = glpi.get_users()
        glpi_users_with_usergroups = glpi.get_users_usergroups()
        glpi_usergroups = glpi.get_usergroups()
        glpi_hosts = glpi.get_hosts(zabbix_host=zabbix.hosts)
        glpi_hostgroups = glpi.get_hostgroups(zabbix_host=zabbix.hosts)
        glpi_computertypes = glpi.get_computertypes()

        logger.info('Logging out of GLPI API')
        glpi.logout()

        logger.info('Updating Zabbix data')
        # creating host groups in Zabbix
        zabbix.create_hostgroups(glpi_hostgroups=glpi_hostgroups)

        # connecting hosts to host groups
        zabbix.update_hosts_groups(
            glpi_hosts=glpi_hosts, glpi_computertypes=glpi_computertypes
        )

        # removing empty host groups
        zabbix.remove_empty_hostgroups()

        # update user groups with appropriate permission (if new host groups
        # have been created)
        zabbix.update_usergroups()

        # creating usergroups
        zabbix.create_usergroups(glpi_usergroups=glpi_usergroups)

        # creating new users and updating old ones, deleting the users which do
        # not exist on GLPI
        zabbix.handle_users(
            glpi_users=glpi_users,
            glpi_users_with_groups=glpi_users_with_usergroups
        )

        # remove empty user groups
        zabbix.delete_usergroups()

        logger.info('logging out of Zabbix API')
        zabbix.logout()

        logger.info('OK')
        sys.exit(0)

    except (ZabbixException, GLPIException) as e:
        logger.error(str(e))
        sys.exit(1)


if __name__ == '__main__':
    main()
