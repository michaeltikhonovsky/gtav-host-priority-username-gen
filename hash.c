#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#define MAX_NAME_LENGTH 16
#define HASH_THRESHOLD 5
#define MAX_MIDDLE_LENGTH 8

static inline uint32_t jenkins_hash(const char *key, size_t length)
{
    uint32_t hash = 0;
    size_t i = 0;

    while (i + 4 <= length)
    {
        hash += key[i];
        hash += (hash << 10);
        hash ^= (hash >> 6);
        hash += key[i + 1];
        hash += (hash << 10);
        hash ^= (hash >> 6);
        hash += key[i + 2];
        hash += (hash << 10);
        hash ^= (hash >> 6);
        hash += key[i + 3];
        hash += (hash << 10);
        hash ^= (hash >> 6);
        i += 4;
    }

    while (i < length)
    {
        hash += key[i];
        hash += (hash << 10);
        hash ^= (hash >> 6);
        i++;
    }

    hash += (hash << 3);
    hash ^= (hash >> 11);
    hash += (hash << 15);
    return hash;
}

static inline char increment_char(char c)
{
    static const char char_map[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    static const char *char_pos[256] = {0};
    static bool initialized = false;

    if (!initialized)
    {
        for (int i = 0; i < 36; i++)
        {
            char_pos[(unsigned char)char_map[i]] = &char_map[i];
        }
        initialized = true;
    }

    const char *pos = char_pos[(unsigned char)c];
    return pos ? (*(pos + 1) ? *(pos + 1) : char_map[0]) : c;
}

static inline void increment_string(char *str, size_t start, size_t end)
{
    for (int i = end - 1; i >= start; i--)
    {
        str[i] = increment_char(str[i]);
        if (str[i] != '0')
            return;
    }
}

int main()
{
    char name[MAX_NAME_LENGTH + 1];
    size_t name_length;
    int format_choice;

    printf("Choose formatting option:\n");
    printf("1. Custom format (000_name_000)\n");
    printf("2. Complete random format\n");
    printf("Enter your choice (1 or 2): ");
    scanf("%d", &format_choice);

    if (format_choice == 1)
    {
        char middle[MAX_MIDDLE_LENGTH + 1];
        printf("Enter the name you are looking for (max %d characters): ", MAX_MIDDLE_LENGTH);
        scanf("%8s", middle);
        snprintf(name, sizeof(name), "000_%s_000", middle);
    }
    else if (format_choice == 2)
    {
        printf("Enter the desired length for random names (max %d): ", MAX_NAME_LENGTH);
        scanf("%zu", &name_length);
        if (name_length > MAX_NAME_LENGTH)
            name_length = MAX_NAME_LENGTH;
        for (size_t i = 0; i < name_length; i++)
            name[i] = '0';
        name[name_length] = '\0';
    }
    else
    {
        printf("Invalid choice. Exiting.\n");
        return 1;
    }

    name_length = strlen(name);
    const size_t prefix_end = (format_choice == 1) ? 3 : 0;
    const size_t suffix_start = (format_choice == 1) ? name_length - 3 : name_length;
    uint64_t count = 0;

    printf("\nChecking hashes for names...\n");
    printf("Press Ctrl+C to stop the program.\n\n");

    while (true)
    {
        uint32_t hash = jenkins_hash(name, name_length);
        if (hash < HASH_THRESHOLD)
        {
            printf("0x%08x: %s\n", hash, name);
        }

        if (format_choice == 1)
        {
            increment_string(name, suffix_start, name_length);
            if (name[suffix_start] == '0' && name[suffix_start + 1] == '0' && name[suffix_start + 2] == '0')
            {
                increment_string(name, 0, prefix_end);
            }
        }
        else
        {
            increment_string(name, 0, name_length);
        }

        if (++count % 100000000 == 0)
        {
            if (count >= 1000000000)
            {
                double billion_count = count / 1000000000.0;
                printf("%.1f billion names\n", billion_count);
            }
            else
            {
                printf("%llu million names\n", count / 1000000);
            }
        }
    }

    return 0;
}