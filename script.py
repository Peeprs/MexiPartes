import re

with open('lib/services/api_services.dart', 'r', encoding='utf-8') as f:
    text = f.read()

if "import 'package:firebase_crashlytics/firebase_crashlytics.dart';" not in text:
    text = "import 'package:firebase_crashlytics/firebase_crashlytics.dart';\n" + text

def rep(match):
    full_string = match.group(1)
    # determine variable name
    var_name = 'e2' if '$e2' in full_string else 'e'
    
    # clean the reason string
    reason = full_string.replace(f': ${var_name}', '').replace(f'${var_name}', '').strip()
    
    return f"FirebaseCrashlytics.instance.recordError({var_name}, StackTrace.current, reason: '{reason}');"

text = re.sub(r'print\("([^"]*\$e2?[^"]*)"\);', rep, text)
text = re.sub(r"print\('([^']*\$e2?[^']*)'\);", rep, text)

# There are also some `print`s without $e like `print("Auto-repair in getUsuarioById failed: $e");` which got covered.
# Wait, what if it's `print("Error: $e");`? All covered.

with open('lib/services/api_services.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Done")
