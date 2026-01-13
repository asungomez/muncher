#!/bin/bash

# Pre-commit hook for muncher monorepo
# Runs linting and formatting on staged files based on which module they belong to

set -e



# Get the root directory of the git repository
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Get all staged files (only added, copied, modified, renamed - not deleted)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR)

if [ -z "$STAGED_FILES" ]; then
    echo "No staged files to check."
    exit 0
fi

# ============================================================================
# Front-end checks
# ============================================================================

# Filter staged files that are in the front-end directory
FRONTEND_FILES=$(echo "$STAGED_FILES" | grep "^front-end/" || true)

if [ -n "$FRONTEND_FILES" ]; then
    echo "🔍 Found staged files in front-end/, running checks..."

    # Filter for files that ESLint cares about
    ESLINT_FILES=$(echo "$FRONTEND_FILES" | grep -E '\.(js|jsx|ts|tsx|mjs|cjs)$' || true)

    # Filter for files that Prettier cares about
    PRETTIER_FILES=$(echo "$FRONTEND_FILES" | grep -E '\.(js|jsx|ts|tsx|mjs|cjs|json|css|scss|md|html|yml|yaml)$' || true)

    cd "$REPO_ROOT/front-end"

    # Run ESLint on applicable files
    if [ -n "$ESLINT_FILES" ]; then
        echo "📝 Running ESLint --fix on staged files..."

        # Convert paths from front-end/src/... to src/... (relative to front-end dir)
        ESLINT_RELATIVE_FILES=$(echo "$ESLINT_FILES" | sed 's|^front-end/||')

        # Run eslint --fix on each file
        echo "$ESLINT_RELATIVE_FILES" | xargs yarn eslint --fix --max-warnings=0

        # Re-add fixed files to staging
        echo "$ESLINT_FILES" | xargs -I {} git add "$REPO_ROOT/{}"
        echo "✅ ESLint passed"
    fi

    # Run Prettier on applicable files
    if [ -n "$PRETTIER_FILES" ]; then
        echo "💅 Running Prettier --write on staged files..."

        # Convert paths from front-end/src/... to src/... (relative to front-end dir)
        PRETTIER_RELATIVE_FILES=$(echo "$PRETTIER_FILES" | sed 's|^front-end/||')

        # Run prettier --write on each file
        echo "$PRETTIER_RELATIVE_FILES" | xargs yarn prettier --write

        # Re-add formatted files to staging
        echo "$PRETTIER_FILES" | xargs -I {} git add "$REPO_ROOT/{}"
        echo "✅ Prettier passed"
    fi

    cd "$REPO_ROOT"
    echo "✨ Front-end checks completed!"
fi

# ============================================================================
# Memoria checks (LaTeX formatting)
# ============================================================================

MEMORIA_FILES=$(echo "$STAGED_FILES" | grep "^memoria/" || true)

if [ -n "$MEMORIA_FILES" ]; then
    echo "🔍 Found staged files in memoria/, running checks..."

    # Set up Perl local::lib if it exists (for latexindent dependencies)
    if [ -d "$HOME/perl5/lib/perl5" ]; then
        eval "$(perl -I"$HOME/perl5/lib/perl5" -Mlocal::lib="$HOME/perl5" 2>/dev/null)" || true
    fi

    # Filter for LaTeX files
    LATEX_FILES=$(echo "$MEMORIA_FILES" | grep -E '\.tex$' || true)

    if [ -n "$LATEX_FILES" ]; then
        # Check if latexindent is available AND working
        # (it may be installed but missing Perl dependencies)
        LATEXINDENT_OK=false
        if command -v latexindent &> /dev/null; then
            # Health check: try to run latexindent on a simple string
            if echo "\\section{test}" | latexindent -s &> /dev/null; then
                LATEXINDENT_OK=true
            fi
        fi

        if [ "$LATEXINDENT_OK" = true ]; then
            echo "📝 Running latexindent on staged .tex files..."

            for FILE in $LATEX_FILES; do
                FULL_PATH="$REPO_ROOT/$FILE"
                echo "   Formatting: $FILE"
                # Run latexindent in-place with silent mode
                if latexindent -s -w "$FULL_PATH" 2>/dev/null; then
                    # Remove backup file created by latexindent
                    rm -f "${FULL_PATH}.bak"
                    # Re-add formatted file to staging
                    git add "$FULL_PATH"
                else
                    echo "   ⚠️  latexindent failed on $FILE (continuing anyway)"
                fi
            done

            echo "✅ latexindent completed"
        else
            echo "⚠️  latexindent not available or not working, skipping LaTeX formatting"
            echo "   To enable: install latexindent's Perl dependencies:"
            echo "   - With admin:  sudo cpan File::HomeDir Log::Log4perl Log::Dispatch Unicode::GCString"
            echo "   - Without admin: cpan -l ~/perl5 File::HomeDir Log::Log4perl Log::Dispatch Unicode::GCString"
            echo "     Then add to ~/.zshrc: eval \"\$(perl -I\$HOME/perl5/lib/perl5 -Mlocal::lib=\$HOME/perl5)\""
        fi
    fi

    echo "✨ Memoria checks completed!"
fi

# ============================================================================
# Done!
# ============================================================================

echo "🎉 Pre-commit checks passed!"
exit 0
