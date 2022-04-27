<?php
// supress PHP output
error_reporting(0);

// check number of arguments
if ($argc < 4 ) {
    die("0");
//    die('Missing arguments!');
}

$origin = gethostname();
//var_dump($argv);
$imap_host = $argv[1];
$smtp_host = $argv[2];
$user = $argv[3];
$pass = $argv[4];
$from = "mailmon@srce.hr";

// Delete all messages from inbox  //

// open IMAP connection
//$mbox = imap_open("{server.srce.hr:port/imap/ssl}INBOX", "user", "password") or die("0");
$mbox = imap_open("{{$imap_host}:993/imap/ssl}INBOX", $user, $pass) or die("0");
// calculate number of messages
$mbox_state=imap_check($mbox);
// mark all messages for deletion
if($mbox_state) {
                //process messages one by one
                for($msgnum=1;$msgnum<=$mbox_state->Nmsgs;$msgnum++) {
                    //delete this message from server
                    imap_delete($mbox, $msgnum);
                }
}

// expunge mails
imap_expunge($mbox);
// close IMAP connection
imap_close($mbox,CL_EXPUNGE);

// Send message //
$cmd = "echo -e \"Subject: Test email\nSys-mon proba za funkcionalni test mail sustava\n\nOrigin: $origin\nIMAP: $imap_host\nSMTP: $smtp_host\" | /bin/msmtp -f $from -a $smtp_host -- $user@srce.hr";
system($cmd,$return_value);
echo $return_value;

?>