Logging In & Transferring Files
================================

For Macs/Linux - Logging In
----------------------------

1. Open a Terminal (usually under Applications/Utilities on a Mac)
2. Cut and paste this into the terminal:

    ssh username@tadpole.genomecenter.ucdavis.edu

where 'username' is replaced with your actual username. Press Enter.

3. Type in your password. No characters will display when you are typing. Press Enter.

For Macs/Linux - Transferring files
------------------------------------

1. Use scp (secure copy, a remote file copying program) to pull a file from the remote server to your local machine:

    scp username@tadpole.genomecenter.ucdavis.edu:[full path to file] .

Replace 'username' with your username and replace '[full path to file]' with the full, *absolute* path to the file you want to transfer. Note that there is a "." at the end of the command (after a space), which is where to put the file, i.e. your current directory. You will have to type in your password.

2. Use scp to push a file from your local machine to the remote server:

    scp [local path to file] username@tadpole.genomecenter.ucdavis.edu:[full path to directory/]

3. See the pattern? ... scp [from] [to]

For Windows - Logging In
-------------------------

1. Open up PuTTY (should be on lab computers). If you haven't installed PuTTY, get it [here](http://www.putty.org/).
2. In the Host Name field, type **tadpole.genomecenter.ucdavis.edu**
3. Make sure the Connection Type is SSH.
4. Press "Open". It will ask you for your username and password.


For Windows - Transferring files
---------------------------------

1. Open up WinSCP (should be on lab computers). If you haven't installed WinSCP, get it [here](https://winscp.net/eng/download.php).
2. In the Host Name field, type **tadpole.genomecenter.ucdavis.edu**
2. Type in your username and password.
3. Make sure the File Protocol is SFTP.
4. Press "Login".

