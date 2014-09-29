#include <Halide.h>
#include <stdio.h>

using namespace Halide;

int main(int argc, char **argv) {
    // First we'll declare some Vars to use below.
    Var x("x"), y("y");
    ImageParam input(Float(32), 2);

    {
        Func output("output");
        output(x, y) += input(x, y);
	output.vectorize(x, 4);

	std::vector<Argument> args;
	args.push_back(input);
	output.compile_to_file("accum_vectorized", args);
    }

    // Same thing, but tiled & vectorized
    {
        Func output("output");
        output(x, y) += input(x, y);

	Var xi, yi;
	output.tile(x, y, xi, yi, 256, 32).vectorize(xi, 4);

	std::vector<Argument> args;
	args.push_back(input);
	output.compile_to_file("accum_tiled", args);
    }

    printf("Success!\n");
    return 0;
}
