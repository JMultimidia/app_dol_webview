#!/bin/bash

echo "🧹 Iniciando Limpeza..."

# 1. Limpeza do Flutter
flutter clean

# 2. Remover pastas temporárias e travamentos
rm -rf .dart_tool
rm -rf .idea
rm -rf .build
rm -rf build
rm -rf pubspec.lock

# -----------------------------------------------------------
# 3. CORREÇÃO DO ERRO ATUAL (Android)
# Remove o cache C++ corrompido que está dando erro no build
# -----------------------------------------------------------
rm -rf android/.gradle
rm -rf android/app/.cxx
rm -rf android/app/build

# -----------------------------------------------------------
# 4. Comandos para iOS / Mac 
# (Descomente abaixo quando estiver no Mac)
# -----------------------------------------------------------

# rm -rf ~/Library/Caches/CocoaPods
# rm -rf ~/Library/Developer/Xcode/DerivedData/*
# chmod -R 755 /Users/johannes/devapps/correiodovale

# cd ios
# rm -rf Pods
# rm Podfile.lock
# pod deintegrate
# pod setup
# pod install
# cd ..

# -----------------------------------------------------------
# 5. Finalização
# -----------------------------------------------------------
echo "📦 Baixando pacotes..."
flutter pub get

echo "✅ Limpeza concluída! Tente rodar o app agora."