/*
 * Minimal legacy initialization hook.
 * C/C++ constructors are handled by __libc_init_array().
 */

// Due to MISRA 8.4: An external function definition should have a prior declaration.
void _init(void);

void _init(void) // NOLINT(bugprone-reserved-identifier)
{
}
