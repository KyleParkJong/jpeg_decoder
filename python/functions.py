import math

def matrix1D_to2D(matrix1D):
    width = int(math.sqrt(len(matrix1D)))
    return [[el for el in matrix1D[x*width:x*width+width]] for x in range(width)]

def matrix2D_to1D(matrix2D):
    matrix1D = []
    for row in matrix2D:
        for element in row:
            matrix1D.append(element)
    return matrix1D


if (__name__ == "__main__"):
    matrix1D = [1,2,3,4]
    matrix2D = matrix1D_to2D(matrix1D)
    print(matrix2D)
    print(matrix2D_to1D(matrix2D))