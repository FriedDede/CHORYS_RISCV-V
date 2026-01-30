
#!/bin/bash

# activate qdma
# echo 512 > /sys/bus/pci/devices/0000\:01\:00.0/qdma/qmax
# add a queue
dma-ctl qdma01000 q add idx 0 mode mm dir h2c 
dma-ctl qdma01000 q add idx 1 mode mm dir c2h

# start a queue
dma-ctl qdma01000 q start idx 0 dir h2c
dma-ctl qdma01000 q start idx 1 dir c2h


# benchmarks (no lu due to time constraint)
names=("2mm" "3mm" "atax" "bicg" "doitgen" "durbin" "gemm" "gemver" "gesummv" "lu" "ludcmp" "mvt" "syr2k" "syrk" "trisolv" "trmm")
output_file="raw_results.log"
> $output_file

for name in "${names[@]}"
do
    echo "Processing: $name" | tee -a "$output_file"
    for i in {1..1}
    do
        # cluster 0
        ./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x0010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x40010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x80010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0xC0010000
#
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x100010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x140010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x180010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x1C0010000
#
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x200010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x240010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x280010000
        #./host_driver/qdma/load_payload.o polybench/build/${name}_0.bin 0x2C0010000



        # disable not used clusters 0
        #./host_driver/qdma/write64_hbm.o 0x0010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x40010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x80010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0xC0010000 0x00000000

        ./host_driver/qdma/write64_hbm.o 0x100010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x140010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x180010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x1C0010000 0x00000000

        ./host_driver/qdma/write64_hbm.o 0x200010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x240010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x280010000 0x00000000
        ./host_driver/qdma/write64_hbm.o 0x2C0010000 0x00000000


        # cluster reboot trigger
        ./host_driver/qdma/reset_cluster.o
        # as we have no interrupt handling we must wait enough time to be sure the bench is completed
        sleep 2
        # cluster 0
        ./host_driver/qdma/read64_hbm.o 0x0000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x40000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x80000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0xC0000100 >> $output_file

        #./host_driver/qdma/read64_hbm.o 0x100000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x140000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x180000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x1C0000100 >> $output_file

        #./host_driver/qdma/read64_hbm.o 0x200000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x240000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x280000100 >> $output_file
        #./host_driver/qdma/read64_hbm.o 0x2C0000100 >> $output_file
        sleep 1
    done
     echo "-" >> "$output_file"
done


python3 process_times.py $output_file results.txt

// stop a queue
dma-ctl qdma01000 q stop idx 0 dir h2c
dma-ctl qdma01000 q stop idx 1 dir c2h 

// remove a queue
dma-ctl qdma01000 q del idx 0 dir h2c
dma-ctl qdma01000 q del idx 1 dir c2h
