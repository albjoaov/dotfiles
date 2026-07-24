#!/bin/bash

# Define um arquivo em sua pasta pessoal para guardar o estado da troca
STATE_FILE="$HOME/.key_swap_active"

# Verifica se o arquivo de estado NÃO existe
if [ ! -f "$STATE_FILE" ]; then
    # ESTADO ATUAL: Padrão
    # AÇÃO: Trocar as teclas

    # 1. Executa a troca
    hidutil property --set '{
        "UserKeyMapping": [
            {
                "HIDKeyboardModifierMappingSrc": 0x7000000E0,
                "HIDKeyboardModifierMappingDst": 0x7000000E3
            },
            {
                "HIDKeyboardModifierMappingSrc": 0x7000000E3,
                "HIDKeyboardModifierMappingDst": 0x7000000E0
            }
        ]
    }'

    # 2. Cria o arquivo de estado para marcar como "trocado"
    touch "$STATE_FILE"

    # 3. Envia uma notificação
    osascript -e 'display notification "Teclas Command e Control TROCADAS" with title "Modificador de Teclas"'

else
    # ESTADO ATUAL: Trocado (arquivo existe)
    # AÇÃO: Restaurar ao padrão

    # 1. Restaura o padrão (lista vazia)
    hidutil property --set '{"UserKeyMapping":[]}'

    # 2. Remove o arquivo de estado para marcar como "padrão"
    rm "$STATE_FILE"

    # 3. Envia uma notificação
    osascript -e 'display notification "Teclas restauradas ao PADRÃO" with title "Modificador de Teclas"'
fi

# Alterna também entre os layouts de teclado Brasileiro e Brasileiro - ABNT2
swift - <<'EOF'
import Carbon

let targets = ["com.apple.keylayout.Brazilian-Pro", "com.apple.keylayout.Brazilian-ABNT2"]

let current = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
guard let curPtr = TISGetInputSourceProperty(current, kTISPropertyInputSourceID) else { exit(0) }
let curID = Unmanaged<CFString>.fromOpaque(curPtr).takeUnretainedValue() as String
guard let idx = targets.firstIndex(of: curID) else { exit(0) }
let nextID = targets[1 - idx]

let list = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
for src in list {
    guard let idPtr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { continue }
    let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
    if id == nextID {
        TISSelectInputSource(src)
        break
    }
}
EOF
