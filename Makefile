.PHONY: build test clean lint format help

help:
	@echo "DesignKit Makefile"
	@echo ""
	@echo "Kullanılabilir komutlar:"
	@echo "  make build    - Paketi derle"
	@echo "  make test     - Testleri çalıştır"
	@echo "  make clean    - Build klasörünü temizle"
	@echo "  make lint     - SwiftLint kontrolü (gerekli: swiftlint)"
	@echo "  make format   - SwiftFormat uygula (gerekli: swiftformat)"

build:
	@echo "📦 DesignKit derleniyor..."
	swift build

test:
	@echo "🧪 Testler çalıştırılıyor..."
	swift test

clean:
	@echo "🧹 Build klasörü temizleniyor..."
	swift package clean
	rm -rf .build

lint:
	@echo "🔍 SwiftLint kontrolü yapılıyor..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --strict; \
	else \
		echo "⚠️  SwiftLint yüklü değil. Yüklemek için: brew install swiftlint"; \
	fi

format:
	@echo "✨ Kod formatlama uygulanıyor..."
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat .; \
	else \
		echo "⚠️  SwiftFormat yüklü değil. Yüklemek için: brew install swiftformat"; \
	fi

