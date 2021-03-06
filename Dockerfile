FROM ewindisch/quagga
MAINTAINER Weitao Han <weitaohan.cn@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y inetutils-ping tcpdump traceroute net-tools vim python openssh-server openbsd-inetd telnetd snmp snmpd nano ethtool libpcap-dev python-pypcap

ENV PATH "/usr/lib/quagga/:/sbin:/bin:/usr/sbin:/usr/bin"

RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config 
RUN echo "telnet stream tcp nowait telnetd /usr/sbin/tcpd /usr/sbin/in.telnetd" >> /etc/inetd.conf 

RUN echo "root:mimic" | chpasswd
RUN useradd mimic  
RUN echo "mimic:mimic" | chpasswd  
RUN echo "mimic ALL=(ALL) ALL" >> /etc/sudoers 

#Fix tcpdump bug
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

COPY $PWD/scapy-2.3.2 /tmp/scapy-2.3.2/
WORKDIR /tmp/scapy-2.3.2
RUN python setup.py install

RUN mkdir /home/mimic
RUN mkdir /var/run/sshd 

WORKDIR /

# Set the timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 22 23 161 162
ENTRYPOINT service openbsd-inetd start && service snmpd start && /usr/sbin/sshd -D	
