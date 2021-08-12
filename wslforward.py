import sys
import platform
import subprocess
import re as regex
from threading import Thread

"""

Update WSL Port Forward

"""

# Thread worker

class Worker(Thread):
  """ This class is for threading. It's minimized.
  """
  def __init__(self, function):
    super().__init__()
    self.function = function

  def run(self):
    self.function()


# Global variables

_distro = ""
_username = ""
_port_source = "22"
_port_dest = "22"


# Scanning for parameter values

def scan_params():
  for i in range(1, len(sys.argv), 2):
    if sys.argv[i] == "-d":
      global _distro
      _distro = sys.argv[i+1]

    elif sys.argv[i] == "-u":
      global _username
      _username = sys.argv[i+1]

    if sys.argv[i] == "-s":
      global _port_source
      _port_source = sys.argv[i+1]

    elif sys.argv[i] == "-p":
      global _port_dest
      _port_dest = sys.argv[i+1]


# Showing How to use this application.

def usage():
  print('\x1b[1;31;47m' + "Update WSL Port Forward" + " \x1b[0m" + '\n')
  print(
    "wslforward " + '\x1b[1;33m' + "[-d <Distro>]" + '\x1b[0m' +
    ' ' + '\x1b[1;33m' + "[-u <Username>]" + '\x1b[0m' +
    ' ' + '\x1b[1;32m' + "[-s SOURCE_PORT]" + '\x1b[0m' +
    ' ' + '\x1b[1;37;42m' + "[-p DEST_PORT]" + '\x1b[0m'
  )
  

if platform.system() != "Windows":
  exit("Sorry, this App is wrttien for Windows.")

if len(sys.argv) == 1:
  usage()
  exit()


try:
  scan_params()
except IndexError as err:
  exit("Missing or invalid parameter value.")

command = "wsl.exe"

if _distro:
  command += " -d " + _distro


def launch_sshd():
  subprocess.run("wsl.exe -d " + _distro + " -- systemctl restart sshd")

worker1 = Worker(launch_sshd)   # "Launch SSHD"
worker1.start()


if _username:
  command += " -u " + _username


ifconfig_result = subprocess.getoutput("wsl.exe -d {} -u {} -- ifconfig".format(_distro, _username))

ip_pattern = regex.compile("^\x20*inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})", regex.IGNORECASE+regex.MULTILINE)

local_ip = ip_pattern.search(ifconfig_result).group(1)


def set_port_forwarding():
  subprocess.run("powershell.exe Start-Process -Verb RunAs netsh.exe 'interface portproxy delete v4tov4 listenport=" + _port_source + " listenaddress=0.0.0.0'")
  subprocess.run("powershell.exe Start-Process -Verb RunAs netsh.exe 'interface portproxy add v4tov4 listenport=" + _port_source + " listenaddress=0.0.0.0 connectport=" + _port_dest + " connectaddress=" + local_ip + "'")

worker2 = Worker(set_port_forwarding)   # "Update Port Forward"
worker2.start()


#result = subprocess.getoutput("netsh interface portproxy show all")
#print(result)