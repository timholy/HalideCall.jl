// Based on:  Halide tutorial lesson 7 and test/static/tiled_blur_generate.cpp

// Compile with the Makefile

#include <Halide.h>
#include <stdio.h>

using namespace Halide;

int main(int argc, char **argv) {
    // First we'll declare some Vars to use below.
    Var x("x"), y("y");
    ImageParam input(Float(32), 2);

    // Now we'll express a multi-stage pipeline that blurs an image
    // first horizontally, and then vertically.
    {
        // Blur it horizontally:
        Func blur_x("blur_x");
        blur_x(x, y) = (input(x-1, y) + input(x, y) + input(x+1, y));

        // Blur it vertically:
        Func output("output");
        output(x, y) = (blur_x(x, y-1) + blur_x(x, y) + blur_x(x, y+1))/9;

	blur_x.compute_root();

	std::vector<Argument> args;
	args.push_back(input);
	//output.compile_to_c("kernels/blur_twopasses.cpp", args, "blur");
	output.compile_to_file("blur_twopasses", args);
    }

    // Same thing, but vectorized
    {
        Func blur_x("blur_x");
        blur_x(x, y) = (input(x-1, y) + input(x, y) + input(x+1, y));

        Func output("output");
        output(x, y) = (blur_x(x, y-1) + blur_x(x, y) + blur_x(x, y+1))/9;

	blur_x.compute_root();
	blur_x.vectorize(x, 4);
	output.vectorize(x, 4);

	std::vector<Argument> args;
	args.push_back(input);
	output.compile_to_file("blur_twopasses_vectorized", args);
    }

    // Same thing, but tiled & vectorized
    {
        Func blur_x("blur_x");
        blur_x(x, y) = (input(x-1, y) + input(x, y) + input(x+1, y));

        Func output("output");
        output(x, y) = (blur_x(x, y-1) + blur_x(x, y) + blur_x(x, y+1))/9;

	Var xi, yi;
	output.tile(x, y, xi, yi, 256, 32).vectorize(xi, 4);
	blur_x.compute_at(output, x).vectorize(x, 4);

	std::vector<Argument> args;
	args.push_back(input);
	output.compile_to_file("blur_tiled", args);
    }

    printf("Success!\n");
    return 0;
}
