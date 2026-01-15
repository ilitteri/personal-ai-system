SHELL := /bin/bash
PERSONAL_DIR := $(HOME)/Personal
SHELL_CONFIG := $(HOME)/.zshrc

.PHONY: setup help

help:
	@echo "Personal AI System"
	@echo ""
	@echo "Usage:"
	@echo "  make setup    - Configure alias and Claude Code permissions"
	@echo "  make help     - Show this help message"

setup:
	@echo "Setting up Personal AI System..."
	@# Add alias if not already present
	@if ! grep -q "alias claudio=" $(SHELL_CONFIG) 2>/dev/null; then \
		echo "" >> $(SHELL_CONFIG); \
		echo "# Claude Code with personal rules" >> $(SHELL_CONFIG); \
		echo "alias claudio='ln -sf ~/Personal/CLAUDE.md ./CLAUDE.md && claude'" >> $(SHELL_CONFIG); \
		echo "✓ Added 'claudio' alias to $(SHELL_CONFIG)"; \
	else \
		echo "✓ Alias already exists in $(SHELL_CONFIG)"; \
	fi
	@# Configure Claude Code permissions
	@mkdir -p $(HOME)/.claude
	@if [ -f $(HOME)/.claude/settings.json ]; then \
		if ! grep -q "Read(~/Personal/\*\*)" $(HOME)/.claude/settings.json 2>/dev/null; then \
			echo "⚠ Please manually add Read(~/Personal/**) to ~/.claude/settings.json permissions"; \
		else \
			echo "✓ Claude Code permissions already configured"; \
		fi \
	else \
		echo '{"permissions":{"allow":["Read(~/Personal/**)"]}}' > $(HOME)/.claude/settings.json; \
		echo "✓ Created Claude Code settings with permissions"; \
	fi
	@echo ""
	@echo "Setup complete! Run 'source $(SHELL_CONFIG)' or open a new terminal."
	@echo "Then use 'claudio' in any project directory."
