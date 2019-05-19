dirdiff
=======

Compare two directories without comparing the files.



Usage
-----

    # dirdiff [OPTIONS] DIR1 DIR2

    Options:
      --help                print this help
      --verbose             verbose output
      --size                compare files by size
      --checking            list files being checked

    Example:
      $ /home/philip/.local/bin/dirdiff -s tmpdir1/ snapshots/hourly.0/
      < IMG_2780.JPG
      M food/es
      > IMG_2755.JPG



Notes
-----

This tiny little script has been written as a replacement
for a diff job that took over half a day to finish,
slowing down the whole pool and causing "dataset is busy" errors.

    $ dirdiff -v /datapool/Temp/ /datapool/Temp/.zfs/snapshot/weekly.0/
    Scanning directory: /datapool/Temp
    Scanning directory: /datapool/Temp/.zfs/snapshot/weekly.0
    Scanned 21440 files in 5.704973 sec



Author
------

Philip Seeger (philip@philip-seeger.de)



