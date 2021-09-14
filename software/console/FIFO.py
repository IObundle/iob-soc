import os

class FIFO_FILE:
    def __init__(self, path):
        self.path = path
        if not os.path.exists(path):
            os.mkfifo(path, mode)
            print('FIFO named ' + str(path) + 'is created successfully.')

    def read(self, number_of_bytes = 1):
        i = 0
        data = bytes()
        # pipein = open(self.path, 'r')
        # print(number_of_bytes)
        while(i<number_of_bytes):
            # data += bytes(pipein.read(), 'ascii')
            # data += bytes(1)
            i += 1
        return data

    def close(self):
        os.remove(self.path)

