# This utility class allows setting the seed for the internal RNG as well as
# generating and returning a new seed.  This allows players to select random
# puzzles to play and replay by setting the seed accordingly.
extends Node

# Set the RNG seed to a given value
static func set_seed(input):
	seed(hash(input))

# Generate and return a new seed
static func gen_seed():
	# Reset RNG
	randomize()
	# Generate a new string based on a random int
	var new_seed = Marshalls.variant_to_base64(randi())
	# Cut off the first and last 5 characters, since they're always the same
	new_seed.erase(0,5)
	new_seed.erase(6,5)
	# Set new seed and return it
	seed(hash(new_seed))
	return new_seed
