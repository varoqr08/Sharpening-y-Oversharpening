from PIL import Image
import numpy as np

f = open("sharpening.txt", "r")

cont = 1
newImage= []


while len(newImage) < 640*480:
    newImage.append((int((f.read(cont*4)))-5000)%1000)
    ++ cont

#print(newImage[15523])

img_pixels = newImage


data = np.array(img_pixels)
data = data.reshape((480, 640))
image = Image.fromarray(data.astype(np.uint8), 'L')
image.save("sharp.png")
image.show()

