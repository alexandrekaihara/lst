from elements.host import Host
from elements.switch import Switch
from elements.link import Link
from elements.controller import Controller

h1 = Host("h1")
h1.instantiate()
h2 = Host("h2")
h2.instantiate()
h3 = Host("h3")
h3.instantiate()
s1 = Switch("s1")
s1.instantiate()
s2 = Switch("s2")
s2.instantiate()

l1 = Link(s1, h1)
l1.setIp(h1, "192.168.56.101", 24)
l1.setIp(s1, "192.168.56.100", 24)

l2 = Link(s1, h2)
l2.setIp(h2, "192.168.56.102", 24)

l3 = Link(s1, s2)

l4 = Link(s2, h3)
l4.setIp(s2, "192.168.100.1", 24)
l4.setIp(h3, "192.168.100.2", 24)


c1 = Controller("c1")
c1.instantiate()

s1.delete()
s2.delete()
h1.delete()
h2.delete()
h3.delete()




c1 = Controller("c1")
c2 = Controller("c2")

h1 = Host("h1")
h1.instantiate()
h2 = Host("h2")
h2.instantiate()
h3 = Host("h3")
h3.instantiate()
h4 = Host("h4")
h4.instantiate()
h5 = Host("h5")
h5.instantiate()

s1 = Switch("s1")
s1.instantiate()
ls1 = Link(c1, s1)
ls1.setIp("192.168.100.100", 32)

s2 = Switch("s2")
s2.instantiate()

# Server subnet
l1 = Link(s1, h1)
l1.setIp(h1, "192.168.100.2", 24)
l1.setIp(s1, "192.168.100.1", 24)

l2 = Link(s1, h2)
l2.setIp(h2, "192.168.200.2", 24)
l1.setIp(s1, "192.168.200.1", 24)

l3 = Link(s1, h3)
l3.setIp(h3, "192.168.210.2", 24)
l3.setIp(s1, "192.168.210.1", 24)

l4 = Link(s1, h4)
l4.setIp(h4, "192.168.220.2", 24)
l4.setIp(s1, "192.168.220.1", 24)

l5 = Link(s1,s2)

l6 = Link(s2, h5)
l6.setIp(h5, "192.168.50.2", 24)
l6.setIp(s2, "192.168.50.1", 24)
