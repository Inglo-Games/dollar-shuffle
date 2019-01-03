extends Node

# Hash the input and make it the seed for the internal RNG
func setup_seed(input):
	seed(input.hash())

# Converts an integer into a base 64 string
func int2base64(num):
	pass

# Generate a new UUID, with input seed if given
func gen_uuid(input):
	# If input isn't null, make it the seed
	if input is null:
		setup_seed(input)
	# Otherwise generate a new random seed
	else:
		randomize()
	# Convert new randi to a base 64 string
	return int2base64(randi())
