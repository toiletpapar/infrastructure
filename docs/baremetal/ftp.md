If you're wondering how I moved these configs to the correct machine do the following:
https://cloudzy.com/blog/how-set-ftp-server-windows-10/

* Wherever the files are hosted, enable ftp
  * On windows you'll need to configure the firewall, enable certain packages, ane ensure ftp is only available on the private network
  * To manage a windows ftp site, go to Computer Management > Services and Applications > Internet Information Services (IIS) Manager
  * Under the host, go to "Sites". You can manage FTP sites there.
* Share `docs/baremetal`
* You can use wget as your ftp client
`wget "ftp://<<ftp server ip>>/<<path to file>>"`