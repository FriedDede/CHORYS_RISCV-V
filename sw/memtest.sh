
#!/bin/bash

# benchmarks (no lu due to time constraint)
names=("mem_seq_write" "mem_seq_read" "mem_seq_rw" "mem_rand_write" "mem_rand_read" "mem_rand_rw")
output_file="raw_results.log"
> $output_file

for name in "${names[@]}"
do
    echo "Processing: $name" | tee -a "$output_file"
    for i in {1..1}
    do
        # cluster 0
        ./host_driver/src/load_payload.o polybench/build/${name}_0.bin 0x0010000
        ./host_driver/src/load_payload.o polybench/build/${name}_1.bin 0x1010000
        ./host_driver/src/load_payload.o polybench/build/${name}_2.bin 0x2010000
        ./host_driver/src/load_payload.o polybench/build/${name}_3.bin 0x3010000
        #./host_driver/src/load_payload.o polybench/build/${name}_4.bin 0x4010000
        #./host_driver/src/load_payload.o polybench/build/${name}_5.bin 0x5010000
        
        # cluster 1
        #./host_driver/src/load_payload.o polybench/build/${name}_6.bin 0x6010000
        #./host_driver/src/load_payload.o polybench/build/${name}_7.bin 0x7010000
        #./host_driver/src/load_payload.o polybench/build/${name}_8.bin 0x8010000
        #./host_driver/src/load_payload.o polybench/build/${name}_9.bin 0x9010000
        #./host_driver/src/load_payload.o polybench/build/${name}_10.bin 0xA010000
        #./host_driver/src/load_payload.o polybench/build/${name}_11.bin 0xB010000
        # cluster 2
        #./host_driver/src/load_payload.o polybench/build/${name}_12.bin 0xC010000
        #./host_driver/src/load_payload.o polybench/build/${name}_13.bin 0xD010000
        #./host_driver/src/load_payload.o polybench/build/${name}_14.bin 0xE010000
        #./host_driver/src/load_payload.o polybench/build/${name}_15.bin 0xF010000
        #./host_driver/src/load_payload.o polybench/build/${name}_16.bin 0x10010000
        #./host_driver/src/load_payload.o polybench/build/${name}_17.bin 0x11010000
        # cluster 3
        #./host_driver/src/load_payload.o polybench/build/${name}_18.bin 0x12010000
        #./host_driver/src/load_payload.o polybench/build/${name}_19.bin 0x13010000
        #./host_driver/src/load_payload.o polybench/build/${name}_20.bin 0x14010000
        #./host_driver/src/load_payload.o polybench/build/${name}_21.bin 0x15010000
        #./host_driver/src/load_payload.o polybench/build/${name}_22.bin 0x16010000
        #./host_driver/src/load_payload.o polybench/build/${name}_23.bin 0x17010000

        # disable not used clusters 0
        #./host_driver/src/write64_hbm.o 0x0010000 0x00000000
        #./host_driver/src/write64_hbm.o 0x1010000 0x00000000
        #./host_driver/src/write64_hbm.o 0x2010000 0x00000000
        #./host_driver/src/write64_hbm.o 0x3010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x4010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x5010000 0x00000000
        
        # disable cluster 1
        ./host_driver/src/write64_hbm.o 0x6010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x7010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x8010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x9010000 0x00000000
        ./host_driver/src/write64_hbm.o 0xA010000 0x00000000
        ./host_driver/src/write64_hbm.o 0xB010000 0x00000000
    
        # disable cluster 2
        ./host_driver/src/write64_hbm.o 0xC010000 0x00000000
        ./host_driver/src/write64_hbm.o 0xD010000 0x00000000
        ./host_driver/src/write64_hbm.o 0xE010000 0x00000000
        ./host_driver/src/write64_hbm.o 0xF010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x10010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x11010000 0x00000000
    
        # disable cluster 3
        ./host_driver/src/write64_hbm.o 0x12010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x13010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x14010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x15010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x16010000 0x00000000
        ./host_driver/src/write64_hbm.o 0x17010000 0x00000000
        # cluster reboot trigger
        ./host_driver/src/reset_cluster.o
        # as we have no interrupt handling we must wait enough time to be sure the bench is completed
        sleep 80
        # cluster 0
        ./host_driver/src/read64_hbm.o 0x100 >> $output_file
        ./host_driver/src/read64_hbm.o 0x108 >> $output_file
        ./host_driver/src/read64_hbm.o 0x110 >> $output_file
        ./host_driver/src/read64_hbm.o 0x118 >> $output_file
        #./host_driver/src/read64_hbm.o 0x120 >> $output_file
        #./host_driver/src/read64_hbm.o 0x128 >> $output_file
        # cluster 1
        #./host_driver/src/read64_hbm.o 0x130 >> $output_file
        #./host_driver/src/read64_hbm.o 0x138 >> $output_file
        #./host_driver/src/read64_hbm.o 0x140 >> $output_file
        #./host_driver/src/read64_hbm.o 0x148 >> $output_file
        #./host_driver/src/read64_hbm.o 0x150 >> $output_file
        #./host_driver/src/read64_hbm.o 0x158 >> $output_file
        # cluster 2
        #./host_driver/src/read64_hbm.o 0x160 >> $output_file
        #./host_driver/src/read64_hbm.o 0x168 >> $output_file
        #./host_driver/src/read64_hbm.o 0x170 >> $output_file
        #./host_driver/src/read64_hbm.o 0x178 >> $output_file
        #./host_driver/src/read64_hbm.o 0x180 >> $output_file
        #./host_driver/src/read64_hbm.o 0x188 >> $output_file
        # cluster 3
        #./host_driver/src/read64_hbm.o 0x190 >> $output_file
        #./host_driver/src/read64_hbm.o 0x198 >> $output_file
        #./host_driver/src/read64_hbm.o 0x1a0 >> $output_file
        #./host_driver/src/read64_hbm.o 0x1a8 >> $output_file
        #./host_driver/src/read64_hbm.o 0x1b0 >> $output_file
        #./host_driver/src/read64_hbm.o 0x1b8 >> $output_file
        
        sleep 1
    done
     echo "-" >> "$output_file"
done


python3 process_times.py $output_file results.txt
