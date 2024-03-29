import std.digest.md;
import std.digest.sha;
import std.getopt;
import std.digest;
import std.stdio;
import std.string;
import std.datetime.systime;
import std.datetime.stopwatch;
import std.conv;
import std.concurrency;

import Color;
import HardInfo;
import BruteForce;

immutable string POSITIVE = "\033[32m[+]\033[39m";
immutable string NEGATIVE = "\033[31m[-]\033[39m";
immutable string SPECIAL = "\033[34m[*]\033[39m";
immutable string VERSION = "0.1.0.8";
immutable string SEPARATROR = "==============================";
immutable uint BENCHMARK_VALUE = 10_000_000;
immutable int KB = 1_000;
immutable int MB = 1_000_000;
immutable int GB = 1_000_000_000;
immutable long TB = 1_000_000_000_000;
immutable double K = 1_000;

string Target = null, Wordlist = null;
bool Verbose = false, Counter = false, Benchmark = false, Hash = false,
    Hardware = false, Brute = false;
int Mode = -1, AlphabetChoice = 3;
uint COUNT = 0;

string HelpMode = "Mode to use for hash function\n\t0 | md5\n\t1 | sha1\n\t2 | sha256\n\t3 | sha512";
string HelpAlphabet = format!"Define alphabet mode\n\t1 | %s\n\t2 | %s\n\t3 | %s (Default)"(BruteForce.ALPHABET,BruteForce.ALPHABET_UPPER,BruteForce.ALPHABET_UPPER_NUMBER);

int main(string[] args)
{
    auto parser = getopt(args, "target|t", "Target value to find", &Target,
            "mode|m", HelpMode, &Mode, "benchmark", "Benchmark mode",
            &Benchmark, "count", "Print count password only", &Counter,
            "wordlist|w", "Wordlist to use for password testing",
            &Wordlist, "hardware-info", "Show hardware info", &Hardware,
            "brute", "Use brute force methods (slow)", &Brute, "hash",
            "Hash text with seleted mode. Use target (-t) options for text to hash",
            &Hash, "alphabet", HelpAlphabet , &AlphabetChoice,"verbose|v", "More verbose output", &Verbose);

    if (parser.helpWanted)
    {
        writefln("\nProgram write by Exo-poulpe %s", VERSION);
        defaultGetoptPrinter("This program break hash from D language.", parser.options);
        writeln("\nExemple : dash -m 0 -t <hash> -w rockyou.txt");
        writeln("\nExemple : dash --hash -m 1 -t \"example\"");

    }
    else if (Hardware)
    {
        writeln(HardWareInfo.ProcessorInfo());
        writeln("OS version : ", HardWareInfo.OSInfo());
    }
    else if (Hash && Target != null && !Brute)
    {
        Digest HASH = null;
        switch (Mode)
        {
        case 0:
            writeln("Mode of hash\t  : MD5");
            HASH = new MD5Digest();
            break;
        case 1:
            writeln("Mode of hash\t  : SHA1");
            HASH = new SHA1Digest();
            break;
        case 2:
            writeln("Mode of hash\t  : SHA256");
            HASH = new SHA256Digest();
            break;
        case 3:
            writeln("Mode of hash\t  : SHA512");
            HASH = new SHA512Digest();
            break;
        default:
            writeln("Mode of hash\t  : MD5");
            HASH = new MD5Digest();
            break;
        }

        writefln("%s : %s", Target, toLower(toHexString(HASH.digest(Target))));
    }
    else if (Target != null && Brute && Wordlist == null)
    {
        Digest HASH = null;
        switch (Mode)
        {
        case 0:
            writeln("Mode of hash\t  : MD5");
            HASH = new MD5Digest();
            break;
        case 1:
            writeln("Mode of hash\t  : SHA1");
            HASH = new SHA1Digest();
            break;
        case 2:
            writeln("Mode of hash\t  : SHA256");
            HASH = new SHA256Digest();
            break;
        case 3:
            writeln("Mode of hash\t  : SHA512");
            HASH = new SHA512Digest();
            break;
        default:
            writeln("Mode of hash\t  : MD5");
            HASH = new MD5Digest();
            break;
        }
        char[] tmp = (AlphabetChoice == 3) ? BruteForce.ALPHABET_UPPER_NUMBER.dup : 
            (AlphabetChoice == 2) ? BruteForce.ALPHABET_UPPER.dup : 
            (AlphabetChoice == 1) ? BruteForce.ALPHABET.dup : BruteForce.ALPHABET_UPPER_NUMBER.dup;
        writefln("Alphabet choose : %s",tmp);
        writeln("Start bruteforcing");
        writeln(SEPARATROR);
        string result = BruteForcing(Target, HASH, tmp,Verbose);

        if (result != "")
        {
            writefln("%s Password found", POSITIVE);
            writefln("%s : %s", Target, result);
        }
        else
        {
            writefln("%s Password not found", NEGATIVE);
        }
        if (Counter)
        {
            writefln("%s Password tested %.0f", SPECIAL, BruteForce.countPassword);
        }
    }
    else if (Benchmark)
    {
        write("Benchmark mode : ");
        Benchmarking();
        return 0;
    }
    else if (Target != null && Mode != -1 && Wordlist != null)
    {
        try
        {
            string start = format!"Start : %s"(Clock.currTime());
            Hasher();
            if (Verbose || Counter)
            {
                writefln("%s Password tested : %u", SPECIAL, COUNT);
            }
            writeln(start);
            writefln("Stop : %s", Clock.currTime());
        }
        catch (Exception ex)
        {
            writeln("Error argument");
            return 2;
        }
    }
    else
    {
        writefln("\nProgram write by Exo-poulpe %s", VERSION);
        defaultGetoptPrinter("This program break hash from D language.", parser.options);
        writeln("\nExemple : dash -m 0 -t <hash> -w rockyou.txt");
        writeln("\nExemple : dash --hash -m 1 -t \"example\"");
    }

    return 0;
}

void HashInfo()
{
    writefln("Wordlist to use   : %s", Wordlist);
    writefln("Hash to find      : %s", Target);
    string tmp = null;
    switch (Mode)
    {
    case 0:
        tmp = "MD5";
        break;
    case 1:
        tmp = "SHA1";
        break;
    case 2:
        tmp = "SHA256";
        break;
    case 3:
        tmp = "SHA512";
        break;
    default:
        tmp = "MD5";
        break;
    }
    writefln("Mode of hash\t  : %s", tmp);
    writefln("%s", SEPARATROR);
}

void Hasher()
{
    HashInfo();
    string tmp = null;
    switch (Mode)
    {
    case 0:
        tmp = HashTesting(Target, Wordlist, new MD5Digest());
        break;
    case 1:
        tmp = HashTesting(Target, Wordlist, new SHA1Digest());
        break;
    case 2:
        tmp = HashTesting(Target, Wordlist, new SHA256Digest());
        break;
    case 3:
        tmp = HashTesting(Target, Wordlist, new SHA512Digest());
        break;
    default:
        writeln("Mode unknow");
        break;
    }

    if (tmp != "")
    {
        writefln("%s Password found", POSITIVE);
        writefln("%s : %s", Target, tmp);
    }
    else
    {
        writefln("%s Password not found", NEGATIVE);
    }
}

string HashTesting(string hash, string wordlist, Digest mode)
{
    string password = "";
    string hashResult = "";
    File f = File(wordlist);
    while (true)
    {
        if (f.eof)
        {
            break;
        }
        password = chomp(f.readln());
        COUNT++;
        hashResult = toLower(toHexString(mode.digest(password)));
        if (Verbose)
        {
            writefln("Password tested : %s :: %s", password, hashResult);
        }
        if (hashResult == hash)
        {
            return password;
        }
    }
    return null;
}

void Benchmarking()
{
    if (Mode == -1)
    {
        Mode = 0;
    }

    switch (Mode)
    {
    case 0:
        writeln("MD5");
        break;
    case 1:
        writeln("SHA1");
        break;
    case 2:
        writeln("SHA256");
        break;
    case 3:
        writeln("SHA512");
        break;
    default:
        writeln("MD5");
        break;
    }

    writeln("Password count : ", BENCHMARK_VALUE);
    writefln("%s", SEPARATROR);
    writefln("Start : %s", Clock.currTime());
    StopWatch sw = StopWatch();
    sw.start();

    for (int i = 0; i < BENCHMARK_VALUE; i++)
    {

        switch (Mode)
        {
        case 0:
            string tmp = toHexString(new MD5Digest().digest(text(i)));
            break;
        case 1:
            string tmp = toHexString(new SHA1Digest().digest(text(i)));
            break;
        case 2:
            string tmp = toHexString(new SHA256Digest().digest(text(i)));
            break;
        case 3:
            string tmp = toHexString(new SHA512Digest().digest(text(i)));
            break;
        default:
            string tmp = toHexString(new MD5Digest().digest(text(i)));
            break;

        }
    }
    sw.stop();
    writefln("Stop : %s", Clock.currTime());
    double tot = BENCHMARK_VALUE / ((sw.peek.total!"msecs") / K);
    writefln("%s Password per seconds : %s", SPECIAL, ToNormalize(tot));
    if (Verbose)
    {
        writeln(SEPARATROR);
        writefln("Time in milliseconds      :  %s", (sw.peek.total!"msecs"));
        writefln("Number of hash generated  :  %u", BENCHMARK_VALUE);
        writefln("Complexity of hash        :  %d", Mode);
        writeln("0 = easy\n1 = medium\n.etc..");
    }
}

string ToNormalize(double tot)
{
    string result = null;
    if (tot > KB && tot < MB)
    {
        result = format!"~%.2f KH/s"(tot / KB);
    }
    else if (tot > MB && tot < GB)
    {
        result = format!"~%.2f MH/s"(tot / MB);

    }
    else if (tot > GB && tot < TB)
    {
        result = format!"~%.2f GH/s"(tot / GB);
    }

    return result;
}
