from PIL import Image
im=Image.open("D:\\ProgramFiles\\vivado_file\\pic_sources\\benben\\9.png")
f=open("D:\\ProgramFiles\\vivado_file\\pic_sources\\benben\\9.coe","w")
width = im.size[0]
height = im.size[1]

rgb_im = im.convert('RGB')
print(width)
print(height)
print(width*height)
print(hex(15))
print(str(hex(15))[-1:])
# f.write("memory_initialization_radix = 16;\n")
# f.write("memory_initialization_vector =\n")
# for i in range(height):
# 	for j in range(width):
# 		r, g, b = rgb_im.getpixel((j,i))
# 		r=r//16;
# 		g=g//16;
# 		b=b//16;
# 		f.write(str(hex(r))[-1:])
# 		f.write(str(hex(g))[-1:])
# 		f.write(str(hex(b))[-1:])
# 		f.write(",\n")

outCount=0;
f.write("memory_initialization_radix = 16;\n")
f.write("memory_initialization_vector =\n")
for i in range(height):
	for j in range(width):
		r, g, b = rgb_im.getpixel((j,i))
		r=r//200;
		f.write(str(hex(r))[-1:])
		outCount+=1;
		if outCount==48:
			f.write(",\n")
			outCount=0;
