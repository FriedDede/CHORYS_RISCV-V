make clean

names=("mem_seq_read" "mem_seq_write" "mem_seq_rw" "mem_rand_write" "mem_rand_read" "mem_rand_rw")
for name in "${names[@]}"
do
    for i in {0..23}
    do
    ./make_polybench.sh snitch ${name} ${i}
    done
done