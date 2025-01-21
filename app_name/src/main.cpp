// say something here

#include <unistd.h>
#include <iostream>

#include "turbo.h"
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#if defined(VERSION_FORMAT_DEV)
#define VERSION_INFO VERSION
#else
#define VERSION_INFO PACKAGE_STRING
#endif

void version(const char *prog) { std::cout << VERSION_INFO << '\n'; }

void usage(const char *prog) { std::cerr << "Usage: " << prog << " [-v|-V]\n"; }

int main(int argc, char **argv)
{
    // if first arg is -v or -V, we print version info
    if ((argc > 1) && ((argv[1][0] == '-') && ((argv[1][1] == 'v') || (argv[1][1] == 'V'))))
    {
        version(argv[0]);
        exit(0);
    }

    // there is only one argument for this app
    if (argc > 1)
    {
        usage(argv[0]);
        exit(1);
    }

    int result = Add(19, 23);
    std::cout << "The answer is: " << result << "\n";

    if (result == 42)
        return 0;
    else
        return 128;
}
