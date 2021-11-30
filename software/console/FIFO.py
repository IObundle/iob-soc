import os

mode = 0o600

class FifoFile:
    def __init__(self, path):
        self.path = path
        if (os.path.exists(path)):
            os.remove(self.path)
        os.mkfifo(path, mode)
        print('FIFO named ' + str(path) + ' is created successfully.')
        self.cnsl = open(self.path, 'wb+', 0)

    def read(self, number_of_bytes = 1):
        i = 0
        data = b''
        # print(number_of_bytes)
        with open(self.path, 'rb', 0) as soc:
            #print("FIFO opened")
            while(i<number_of_bytes):
                data += soc.read(1)
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
        with open(self.path, 'rb', 0) as soc:
            #print("FIFO opened")
            while(True):
                data += soc.read(1)
                if len(data) == b'':
                    print("Writer closed")
                    break
                #print('Read: "{0}"'.format(data))
                if (data == end):
                    break
            return data

    def write(self, data):
        self.cnsl.write(data)
        self.cnsl.flush()

    def close(self):
        os.remove(self.path)
        print('Removed file: "{0}"'.format(self.path))
