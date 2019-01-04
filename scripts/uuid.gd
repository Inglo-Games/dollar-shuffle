extends Node

# Hash the input and make it the seed for the internal RNG
static func setup_seed(input):
	seed(input.hash())

# Generate a new UUID, with input seed if given
static func gen_uuid(input):
	# If input isn't null, make it the seed
	if input != null:
		setup_seed(input)
	# Otherwise generate a new random seed
	else:
		randomize()
	# Convert new randi to a base 64 string
	return Marshalls.variant_to_base64(randi())
