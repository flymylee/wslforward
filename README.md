# Update WSL Port Forward

## What's this?

1. Update internal port forward settings with private IP of selected WSL machine
2. If you don't enter port number, the default value (22; for SSH) will be used
3. This app is written for [WSL](https://docs.microsoft.com/ko-kr/windows/wsl/) and [Rocky Linux 8](https://rockylinux.org/)

## How to use (Python)

0. First of all, **install python 3.x** on your computer

1. If you don't know what to do, just type as following

```command
python wslforward.py -u root
```

2. At the finish, check the result please

```command
C:\Users\USER>netsh.exe interface portproxy show all

Listen on ipv4:             Connect to ipv4:

Address         Port        Address         Port
--------------- ----------  --------------- ----------
0.0.0.0         22          {IP_ADDRESS}    22

```

## How to use (Windows Batch Script)

0. First, you need to put your WSL distro name, login name and connection port on the script.

```batch
SET _Distro=Rocky8
SET _Username=rocky
SET _Port_Ingress=22
SET _Port_Egress=%_Port_Ingress%
SET _WSL_IP={Automatic Input}
```

1. You get started with this. How to is the following:

```command
wslforward.cmd
```

2. Check the proxy addresss.

```command
C:\Users\USER>netsh.exe interface portproxy show all

Listen on ipv4:             Connect to ipv4:

Address         Port        Address         Port
--------------- ----------  --------------- ----------
0.0.0.0         22          {_WSL_IP}    22

```

3. Now, you can access your WSL server from out of the host computer

## Available Commands

- **-d <Distro>** selects the WSL distribution which will be port forwarded
- **-u <Username>** selects the user on the WSL distribution while the excecution of some commands
- **-s <_Port_Ingress>** sets the source(listening) port. It's used for access from the outside to your WSL
- **-p <_Port_Egress>** sets the destination port, which your server on WSL uses

## Acknowledgements

- This code refers to the following
  1. [ANSI colors for python](https://pypi.org/project/ansicolors/) and its references
  2. 'Threading' section of [레벨업 파이썬(Level-Up Python)](https://wikidocs.net/82581#threading)
  3. [Regular Expression HOWTO](https://docs.python.org/ko/3/howto/regex.html)
  4. [Configuring Port Forwarding on Windows | Windows OS Hub](http://woshub.com/port-forwarding-in-windows/)
- This app needs at least one parameter value. I think using 'root' as username is easy.

## License

- [Update WSL Port Forward](https://github.com/flymylee/wslforward/blob/master/LICENSE) is licensed under the WTFPL license.
