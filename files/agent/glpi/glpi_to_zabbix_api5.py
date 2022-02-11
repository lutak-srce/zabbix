#!/usr/bin/python
import random
import re
import string
import sys
import xmlrpclib

import argparse
import logging
import logging.handlers
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
        return 'Zabbix: ' + str(self.msg)


def logger_setup():
    logger = logging.getLogger('glpi2zabbix')
    logger.setLevel(logging.INFO)

    # setting up logging to file
    logfile = logging.handlers.SysLogHandler(address='/dev/log')
    logfile.setLevel(logging.INFO)
    logfile.setFormatter(
        logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
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
    def __init__(self, url, username, password):
        self.url = strip_trailing_slash(url) + '/plugins/webservices/xmlrpc.php'
        self.username = username
        self.password = password
        self.server = None
        self.session = None
        self.all_users = None

    def get_users(self):
        """
        Get all the users with '@srce.hr' from GLPI.
        :return: list of users with '@srce.hr' in name
        """
        try:
            users = self.server.glpi.listUsers(
                {'session': self.session, 'limit': 10000}
            )

            srce_users = [d for d in users if 'srce.hr' in d['name']]

            self.all_users = srce_users

            return srce_users

        except Exception, e:
            raise GLPIException(msg='Error fetching users: ' + str(e))

    def _get_groups(self):
        """
        Get groups from GLPI.
        :return: tuple: list of unique nonempty user groups, dict of users and
        their user groups.
        """
        try:
            # all the groups in GLPI
            groups = self.server.glpi.listGroups(
                {'session': self.session, 'limit': 10000}
            )

            # groups with associated users
            groups_with_users = dict()
            for group in groups:
                usergroup = self.server.glpi.listUsers({
                    'session': self.session, 'limit': 10000,
                    'group': group['id']
                })
                groups_with_users.update({
                    group['name']: [d.get('name', None) for d in usergroup]
                })

            # associated groups for every user
            users_with_groups = dict()
            if self.all_users:
                all_users = self.all_users
            else:
                all_users = self.get_users()

            for user in all_users:
                users_with_groups.update({
                    user['name']:
                        [key for key, value in groups_with_users.items()
                         if user['name'] in value]
                })

            # Keeping only user groups which contain users
            usergroups_unique = set()
            for key, value in users_with_groups.items():
                for item in value:
                    usergroups_unique.add(item)

            return list(usergroups_unique), users_with_groups

        except Exception, e:
            raise GLPIException(msg='Error fetching groups: ' + str(e))

    def _get_hosts(self):
        """
        :return: list of hosts on GLPI with detailed information.
        """
        try:
            hosts = self.server.glpi.listObjects(
                {
                    'session': self.session,
                    'limit': 10000,
                    'itemtype': 'Computer'
                }
            )

            # Computers detailed data
            computers = list()
            for host in hosts:
                computers.append(
                    self.server.glpi.getObject(
                        {
                            'session': self.session,
                            'id': host['id'],
                            'show_name': 1,
                            'itemtype': 'Computer'
                        }
                    )
                )

            self.all_hosts = computers

            return computers

        except Exception, e:
            raise GLPIException(msg='Error fetching hosts: ' + str(e))

    def get_computertypes(self):
        """
        :return: list of computer types as defined in GLPI.
        """
        try:
            computertypes = self.server.glpi.listDropdownValues(
                {'session': self.session, 'dropdown': 'ComputerType'}
            )

            return [t['name'] for t in computertypes]

        except Exception, e:
            raise GLPIException(msg='Error fetching computer types: ' + str(e))

    def login(self):
        try:
            self.server = xmlrpclib.ServerProxy(self.url)
            result = self.server.glpi.doLogin(
                {'login_name': self.username, 'login_password': self.password}
            )

            self.session = result['session']

        except xmlrpclib.Fault, e:
            raise GLPIException(msg='Error during login: ' + str(e))

    def logout(self):
        try:
            self.server.glpi.doLogout({'session': self.session})

        except xmlrpclib.Fault, e:
            raise GLPIException(msg='Error during logout: ' + str(e))

    def get_unique_usergroups(self):
        return self._get_groups()[0]

    def get_users_with_usergroups(self):
        return self._get_groups()[1]

    def get_hosts_hostgroups(self, zabbix_host):
        """
        Get hosts from GLPI which exist on Zabbix and their host groups.
        :param zabbix_host: list of host's names in Zabbix.
        :return: tuple: list of host's names from GLPI which exist on Zabbix,
        list of unique host groups which contain aforementioned hosts.
        """
        try:
            glpi_hostgroups_unique = set()
            glpi_hosts_zabbix = list()
            for item in self._get_hosts():
                if any(
                        d.get('name', None) == item['name'] for d in zabbix_host
                ):
                    glpi_hosts_zabbix.append(item)
                    if 'computertypes_name' in item.keys():
                        glpi_hostgroups_unique.add(item['computertypes_name'])
                    if 'groups_name' in item.keys():
                        glpi_hostgroups_unique.add(item['groups_name'])
                    if 'groups_name_tech' in item.keys():
                        glpi_hostgroups_unique.add(item['groups_name_tech'])

            return glpi_hosts_zabbix, list(glpi_hostgroups_unique)

        except Exception, e:
            raise GLPIException(msg='Error fetching hosts: ' + str(e))


class Zabbix:
    def __init__(self, url, username, password):
        self.url = strip_trailing_slash(url)
        self.username = username
        self.password = password
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
            self.server = ZabbixAPI(self.url + '/api_jsonrpc.php')
            self.server.login(self.username, self.password)
            self._get_initial_data()

        except ZabbixAPIException, e:
            raise ZabbixException(msg='Error during login: ' + str(e))

    def logout(self):
        try:
            self.server.user.logout()

        except ZabbixAPIException, e:
            raise ZabbixException(msg='Error during logout: ' + str(e))

    def _get_hosts(self):
        try:
            return self.server.host.get()

        except ZabbixAPIException, e:
            raise ZabbixException(msg='Error fetching hosts: ' + str(e))

    def _get_hostgroups(self):
        try:
            return self.server.hostgroup.get()

        except ZabbixAPIException, e:
            raise ZabbixException(msg='Error fetching host groups: ' + str(e))

    def _get_users(self):
        try:
            return self.server.user.get(output='extend')

        except ZabbixAPIException, e:
            raise ZabbixException(msg='Error fetching users: ' + str(e))

    def _get_usergroups(self):
        try:
            return self.server.usergroup.get(selectRights=1)

        except ZabbixAPIException, e:
            raise ZabbixException(msg='Error fetching user groups: ' + str(e))

    def create_hostgroups(self, glpi_hostgroups):
        """
        Creating hostgroups for hosts existing on Zabbix.
        :param glpi_hostgroups: list of unique host groups' names from GLPI
        """
        try:
            new_hostgroup = list()
            for item in glpi_hostgroups:
                # if it does not exist, create it
                if not any(
                        d.get('name', None) == item for d in self.hostgroups
                ):
                    self.server.hostgroup.create(name=item)
                    new_hostgroup.append(item)

            self.new_hostgroups = new_hostgroup

        except Exception, e:
            raise ZabbixException(msg='Error creating host groups: ' + str(e))

    def update_hosts_groups(self, glpi_hosts, glpi_computertypes):
        """
        Update hosts with host groups according to GLPI data.
        :param glpi_hosts: list detailed hosts from GLPI
        :param glpi_computertypes: list of computer types as defined in GLPI
        """
        try:
            glpi_group_pattern = re.compile('\d{3}-\d{2}-\d{3}')
            for item in glpi_hosts:
                zabbix_host_id = [
                    d.get('hostid') for d in self.hosts
                    if d.get('name') == item['name']
                ][0]
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
                    zabbix_hostgroup_with_host = self.server.hostgroup.get(
                        hostids=zabbix_host_id
                    )

                    zabbix_hostgroup_names = set(
                        item['name'] for item in zabbix_hostgroup_with_host
                    )

                    update = list(glpi_hostgroup.union(zabbix_hostgroup_names))
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
                                    d.get('groupid') for d in self.hostgroups
                                    if d.get('name') == i
                                ]
                                if x2:
                                    zabbix_hostgroup_update.append(
                                        {'groupid': int(x2[0])}
                                    )

                        self.server.host.update(
                            hostid=zabbix_host_id,
                            groups=zabbix_hostgroup_update
                        )

        except Exception, e:
            raise ZabbixException(
                msg='Error updating hosts with host groups: ' + str(e)
            )

    def remove_empty_hostgroups(self):
        """
        Remove host groups which are left empty.
        """
        try:
            hostgroups_with_hosts = self.server.hostgroup.get(real_hosts=1)

            # some groups SHOULD NOT be deleted
            not_deletable = ['Templates', 'Hypervisors', 'Virtual machines'] + \
                            [g.get('name') for g in self.hostgroups
                             if re.search(
                                'template', g.get('name'), re.IGNORECASE)
                             ]
            hostgroups_with_hosts = hostgroups_with_hosts + [
                g for g in self.hostgroups if g.get('name') in not_deletable
            ]

            empty_hostgroups = [
                eg for eg in self.hostgroups if eg not in hostgroups_with_hosts
            ]

            if empty_hostgroups:
                for item in empty_hostgroups:
                    self.server.hostgroup.delete(int(item['groupid']))

        except Exception, e:
            raise ZabbixException(
                msg='Error removing empty host groups: ' + str(e)
            )

    def update_usergroups(self):
        """
        If there has been new host groups created, update user groups with
        appropriate permissions.
        """
        try:
            # update host groups
            self.hostgroups = self._get_hostgroups()

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
                        self.server.usergroup.update(
                            usrgrpid=usrid[0],
                            rights={'permission': 3, 'id': grpid[0]}
                        )

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

        except Exception, e:
            raise ZabbixException(msg='Error updating user groups' + str(e))

    def create_usergroups(self, glpi_usergroups):
        """
        Creating user groups if they do not exist in Zabbix. If the host group
        with the same name exists, assign appropriate permission to newly
        created user group.
        :param glpi_usergroups: unique user groups from GLPI
        """
        try:
            for item in glpi_usergroups:
                if not any(
                        d.get('name', None) == item for d in self.usergroups
                ):
                    hostgrpid = [
                        d.get('groupid') for d in self.hostgroups
                        if d.get('name') == item
                    ]
                    if hostgrpid:
                        self.server.usergroup.create(
                            name=item,
                            rights={"permission": 3, "id": hostgrpid[0]}
                        )
                    else:
                        self.server.usergroup.create(name=item)

        except Exception, e:
            raise ZabbixException(msg='Error creating user groups: ' + str(e))

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
            try:
                if not any(d.get('alias', None) == key for d in self.users):
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

                    self.server.user.create(
                        alias=key, passwd=generate_random_alphanum_string(30),
                        usrgrps=grpid, name=name, surname=surname, type=usertype
                    )

                else:
                    usrid = [
                        d.get('userid') for d in self.users if
                        key == d.get('alias')
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
                        if key == d.get('alias')
                    ][0]

                    if glpi_name != zabbix_name:
                        self.server.user.update(userid=usrid, name=glpi_name)

                    glpi_surname = [
                        d.get('realname') for d in glpi_users
                        if key == d.get('name')
                    ]

                    if glpi_surname:
                        glpi_surname = glpi_surname[0]
                    zabbix_surname = [
                        d.get('surname') for d in self.users
                        if key == d.get('alias')
                    ][0]
                    if glpi_surname != zabbix_surname:
                        self.server.user.update(
                            userid=usrid, surname=glpi_surname
                        )

                    usrgrp = self.server.usergroup.get(userids=usrid)
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
                            d.get('type') for d in self.users
                            if d.get('alias') == key
                        ][0]
                        if usrtype == '3':
                            self.server.user.update(
                                userid=usrid, usrgrps=usrgrpids,
                                passwd=generate_random_alphanum_string(30)
                            )
                        else:
                            if len(usrgrplist) > 1:
                                self.server.user.update(
                                    userid=usrid, usrgrps=usrgrpids, type=2,
                                    passwd=generate_random_alphanum_string(30)
                                )
                            else:
                                self.server.user.update(
                                    userid=usrid, usrgrps=usrgrpids, type=1,
                                    passwd=generate_random_alphanum_string(30)
                                )

            except Exception, e:
                raise ZabbixException(
                    'Error handling user %s: %s' % (key, str(e))
                )

        try:
            # Default Zabbix users
            defaultusersalias = ['guest', 'apiuser', 'nagios', 'Admin']
            default_users = [
                d for d in self.users if d.get('alias') in defaultusersalias
            ]
            superadmin = [d for d in self.users if d.get('type') == '3']
            default_users = default_users + superadmin

            # Remove users from Zabbix which don't exist on GLPI (except the
            # default ones)
            for item in self.users:
                if not any(
                        d.get('name', None) == item['alias'] for d in glpi_users
                ) and item not in default_users:
                    self.server.user.delete(item['userid'])

        except Exception, e:
            raise ZabbixException('Error handling users: ' + str(e))

    def delete_usergroups(self):
        """
        Remove empty user groups, except for the default ones.
        """
        try:
            # Returns the users from the user group in the users property.
            usergroups = self.server.usergroup.get(selectUsers=1)

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
                    self.server.usergroup.delete(item['usrgrpid'])

        except Exception, e:
            raise ZabbixException(msg='Error deleting user groups: ' + str(e))


def main():
    logger = logger_setup()

    logger.info('Processing started')

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--glpi_url', dest='glpi_url', help='GLPI url', type=str, required=True
    )
    parser.add_argument(
        '--glpi_username', dest='glpi_username', help='GLPI username', type=str,
        required=True
    )
    parser.add_argument(
        '--glpi_password', dest='glpi_password', help='GLPI password', type=str,
        required=True
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
    glpi_username = args.glpi_username
    glpi_password = args.glpi_password
    zabbix_url = args.zabbix_url
    zabbix_username = args.zabbix_username
    zabbix_password = args.zabbix_password

    # Initializing GLPI and Zabbix classes
    glpi = GLPI(
        url=glpi_url,
        username=glpi_username,
        password=glpi_password
    )

    zabbix = Zabbix(
        url=zabbix_url,
        username=zabbix_username,
        password=zabbix_password
    )

    try:
        logger.info('Logging into GLPI API')
        glpi.login()
        logger.info('Logging into Zabbix API')
        zabbix.login()

    except xmlrpclib.Fault, e:
        logger.error('GLPI logging error: ' + str(e))
        sys.exit(1)

    except ZabbixAPIException, e:
        logger.error('Zabbix logging error: ' + str(e))
        sys.exit(1)

    try:
        logger.info('Fetching GLPI data')
        glpi_users = glpi.get_users()
        glpi_users_with_usergroups = glpi.get_users_with_usergroups()
        glpi_usergroups = glpi.get_unique_usergroups()
        glpi_hosts, glpi_hostgroups = glpi.get_hosts_hostgroups(
            zabbix_host=zabbix.hosts
        )
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

    except [ZabbixException, GLPIException], e:
        logger.error(str(e))
        sys.exit(1)


if __name__ == '__main__':
    main()
