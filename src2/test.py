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

lh1h2 = Link(s1, h1, "vethsh1h1", "vethh1s1")
lh1h2.connect("192.168.56.100", 24, "192.168.56.101", 24)

s1.delete()
s2.delete()

