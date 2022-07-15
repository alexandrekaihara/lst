# Copyright (C) 2022 Alexandre Mitsuru Kaihara
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# This class holds the values of the network node link and some
class Link():
    def __init__(self, object):
        self._peer1 = self.set_peer1(object)
        self._peer2 = self.set_peer2(object)

    # Brief: Set the peer1 parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the peer1 if exists, otherwise, returns none
    def set_peer1(self, object):
        pass

    # Brief: Set the peer2 parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the peer2 if exists, otherwise, returns none
    def set_peer2(self, object):
        pass
    
    # Brief: Returns the value of peer1
    # Params:
    # Return:
    #   Returns the value of the peer1
    def get_peer1(self):
        return self._peer1

    # Brief: Returns the peer2
    # Params:
    # Return:
    #   Return the value of the peer2
    def get_peer2(self):
        return self._peer2

    