import os

mode = 0o600

class FifoFile:
    def __init__(self, path):
        self.path = path
        if (os.path.exists(path)):
            os.remove(self.path)
        os.mkfifo(path, mode)
        print('FIFO named ' + str(path) + ' is created successfully.')
        self.fifo = open(self.path, 'wb+', 0)

    def read(self, number_of_bytes = 1):
        i = 0
        data = b''
        # print(number_of_bytes)
        while(i<number_of_bytes):
            data += self.fifo.read(1)
            if len(data) == b'':
                print("Writer closed")
                break
            #print('Read: "{0}"'.format(data))
            i += 1
        return data

    def read_until(self, end = b'\x00'):
        i = 0
        data = b''
        # print(number_of_bytes)
        while(True):
            byte = self.fifo.read(1)
            data += byte
            if len(data) == b'':
                print("Writer closed")
                break
            #print('Read: "{0}"'.format(data))
            if (byte == end):
                return data

    def write(self, data):
        self.fifo.write(data)
        self.fifo.flush()

    def close(self):
        os.remove(self.path)
        print('Removed file: "{0}"'.format(self.path))
