for i in $(seq 2605 2924)
       do
          sbatch SENC_Olympus_Batch_zipping_unix.txt $i

done

