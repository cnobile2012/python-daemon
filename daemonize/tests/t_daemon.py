#
# daemonize/tests/t_daemon.py
#
from __future__ import absolute_import

import os
import sys
import time

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__))))
sys.path.append(BASE_DIR)

from daemonize import Daemon

LOG_PATH = os.path.join(BASE_DIR, 'logs')


class TDaemon(Daemon):
    daemon = os.path.join(LOG_PATH, 'testing_daemon.txt')

    def __init__(self, *args, **kwargs):
        super(TDaemon, self).__init__(*args, **kwargs)
        testoutput = open(self.daemon, 'w')
        testoutput.write('inited')
        testoutput.close()

    def run(self):
        time.sleep(0.3)
        testoutput = open(self.daemon, 'w')
        testoutput.write('finished')
        testoutput.close()


if __name__ == '__main__':
    if len(sys.argv) == 1:
        unittest.main()
    elif len(sys.argv) == 2:
        arg = sys.argv[1]

        if arg in ('start', 'stop', 'restart'):
            pidfile = os.path.join(LOG_PATH, 'testing_daemon.pid')
            d = TDaemon(pidfile, verbose=2)
            getattr(d, arg)()
