from __future__ import annotations

import hashlib
from pathlib import Path


EXPECTED_HASHES = {
    "references/originals/write-clean-readable-code/SKILL.md": "1A1E850E31D644944F5082A42BA9C1DFA0E8AD6700936CD1ADD23DD3257B3345",
    "references/originals/write-clean-readable-code/agents/openai.yaml": "CE57A0268740ACD113AAD7020CA8A28C3CDCFA9400D6032DE7E6FC0513A63785",
    "references/originals/minimal-change-fix/SKILL.md": "4A9ED61ED8476E0D84A95C72137C537E0F265F7976C079E7D0E331987C758333",
    "references/originals/minimal-change-fix/agents/openai.yaml": "734E33E57974EEA1F31C6EFE379B54824E430BF5E91D3585B7874B43EB7479E3",
    "references/originals/code-refactorer/SKILL.md": "38D3AFD64751C1A683414D15A75C7F7E18CC3B80D404050F05C0A9B41C25B385",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def main() -> int:
    skill_root = Path(__file__).resolve().parent.parent
    failures: list[str] = []

    for relative_path, expected_hash in EXPECTED_HASHES.items():
        path = skill_root / relative_path
        if not path.is_file():
            failures.append(f"Missing: {relative_path}")
            continue

        actual_hash = sha256(path)
        if actual_hash != expected_hash:
            failures.append(
                f"Hash mismatch: {relative_path}\n"
                f"  expected: {expected_hash}\n"
                f"  actual:   {actual_hash}"
            )

    if failures:
        print("\n".join(failures))
        return 1

    print(f"Verified {len(EXPECTED_HASHES)} preserved source artifacts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
