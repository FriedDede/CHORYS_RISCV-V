make clean

names=("2mm" "3mm" "atax" "bicg" "doitgen" "durbin" "gemm" "gemver" "gesummv" "lu" "ludcmp" "mvt" "syr2k" "syrk" "trisolv" "trmm")
for name in "${names[@]}"
do
    for i in {0..0}
    do
    ./make_polybench.sh snitch ${name} ${i}
    done
done