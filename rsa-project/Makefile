all:	
	vivado -mode batch -source build.tcl	
	ln -s ../src/sdk/ rsa_project/rsa_project.sdk

open:
	vivado rsa_project/rsa_project.xpr -tempDir /tmp &

downloadupdate: 
	cp -fr /users/cosic/fturan/DDP/update2/rsa-project/. . 

uart:
	screen /dev/ttyUSB1 115200

clean:
	rm vivado.* vivado_* .Xil/ -rf webtalk* -f

cleanall: clean
	rm -rf rsa_project

update: clean cleanall downloadupdate all
