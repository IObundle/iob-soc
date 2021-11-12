import os

mode = 0o600

class FifoFile:
    def __init__(self, path):
        self.path = path
        if not os.path.exists(path):
            os.mkfifo(path, mode)
            print('FIFO named ' + str(path) + 'is created successfully.')

    def read(self, number_of_bytes = 1):
        i = 0
        data = b''
        # print(number_of_bytes)
        with open(self.path) as fifo:
            print("FIFO opened")
            while(i<number_of_bytes):
                data += bytes(fifo.read(1), 'ascii')
                if len(data) == b'':
                    print("Writer closed")
                    break
                print('Read: "{0}"'.format(data))
                i += 1
            return data

    def read_until(self, end = b'\x00'):
        i = 0
        data = b''
        # print(number_of_bytes)
        with open(self.path) as fifo:
            print("FIFO opened")
            while(True):
                data += bytes(fifo.read(1), 'ascii')
                if len(data) == b'':
                    print("Writer closed")
                    break
                print('Read: "{0}"'.format(data))
                if (data == end):
                    break
            return data

    def write(self, data):
        with open(self.path, 'wb') as fifo:
            fifo.write(data)

    def close(self):
        os.remove(self.path)
        print('Removed file: "{0}"'.format(self.path))
