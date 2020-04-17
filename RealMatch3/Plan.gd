extends Node

# BUG
# 1.a problem is swap_back will not perform properly when swapping two fast
# after swap, only check the swapped piece.
# move check null to _process and do it all the time
# 2. dim is too early to be shown.
# 3. in some special situation, one piece will be put into two position in all_pieces
#    and it may be induced by deleted object
# 4. if drag mouse botton out of the window, get_cellv return -1 or 0, and these numbers are not in the dict.
# abandon the dict, use tileid instead

# Plan
# Add explosion and flash
# loop from end to generator
# make a counter
# optimize the swap input function
# remove the last two pool list

# Thoughts
# deleted object is a really terrible thing. Just check it and make it null.
# 000.source and sink
