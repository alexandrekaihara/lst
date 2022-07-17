from elements.host import Host
from elements.host import Switch
from elements.host import Link
from elements.host import Controller

h1 = Host("h1")
h2 = Host("h2")
lh1h2 = Link(h1, h2, "veth1", "veth2")
lh1h2.connect("192.168.56.100", "192.168.56.101")

