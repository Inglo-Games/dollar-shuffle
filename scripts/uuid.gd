extends Node

# Generate a new UUID, with input seed if given
static func gen_uuid(input):
	# If input isn't null, make it the seed
	if input != null:
		seed(input.hash())
	# Otherwise generate a new random seed
	else:
		randomize()
	# Convert new randi to a base 64 string
	return Marshalls.variant_to_base64(randi())
