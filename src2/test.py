from elements.host import Host
from elements.switch import Switch
from elements.link import Link
from elements.controller import Controller

h1 = Host("h1")
h1.instantiate()
h2 = Host("h2")
h2.instantiate()
s1 = Switch("s1")
s1.instantiate()

l1 = Link(s1, h1)
l1.setIp(h1, "192.168.56.101", 24)
l1.setIp(s1, "192.168.56.100", 24)

l2 = Link(s1, h2, "veths1h2", "vethh2s1")
l2.connect("192.168.56.100", 24, "192.168.56.102", 24)

s1.delete()
s2.delete()

