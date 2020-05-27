from PIL import Image
from numpy import asarray
from matplotlib import pyplot

img = Image.open('Lena.jpg').convert('LA')
img = img.resize((640,480))
img.save('greyScale.png')


#img.show()

pix_val = list(img.getdata())
pix_val_flat = [x for sets in pix_val for x in sets]

aux = []

while pix_val_flat != []:
    x = pix_val_flat.pop(0)
    if x == 0:
        x = '000'
        aux.append(x)
        pix_val_flat.pop(0)   
    elif x < 10:
        x = '00'+str(x)
        aux.append(x)
        pix_val_flat.pop(0)        
    elif x < 100:
        x = '0'+str(x)
        aux.append(x)
        pix_val_flat.pop(0)
    else:
        aux.append(str(x))
        pix_val_flat.pop(0)

print(len(aux))
print(aux[15523])

imageData = aux

fh = open('image.txt', 'w')
listToStr = ''.join([value for value in imageData]) 
fh.write(listToStr)
fh.close

