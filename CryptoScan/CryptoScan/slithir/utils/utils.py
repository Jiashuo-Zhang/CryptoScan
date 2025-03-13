from typing import Union, Optional

from CryptoScan.core.variables.local_variable import LocalVariable
from CryptoScan.core.variables.state_variable import StateVariable

from CryptoScan.core.declarations.solidity_variables import SolidityVariable
from CryptoScan.core.variables.top_level_variable import TopLevelVariable

from CryptoScan.slithir.variables.temporary import TemporaryVariable
from CryptoScan.slithir.variables.constant import Constant
from CryptoScan.slithir.variables.reference import ReferenceVariable
from CryptoScan.slithir.variables.tuple import TupleVariable
from CryptoScan.core.source_mapping.source_mapping import SourceMapping

RVALUE = Union[
    StateVariable,
    LocalVariable,
    TopLevelVariable,
    TemporaryVariable,
    Constant,
    SolidityVariable,
    ReferenceVariable,
]

LVALUE = Union[
    StateVariable,
    LocalVariable,
    TemporaryVariable,
    ReferenceVariable,
    TupleVariable,
]


def is_valid_rvalue(v: Optional[SourceMapping]) -> bool:
    return isinstance(
        v,
        (
            StateVariable,
            LocalVariable,
            TopLevelVariable,
            TemporaryVariable,
            Constant,
            SolidityVariable,
            ReferenceVariable,
        ),
    )


def is_valid_lvalue(v: Optional[SourceMapping]) -> bool:
    return isinstance(
        v,
        (
            StateVariable,
            LocalVariable,
            TemporaryVariable,
            ReferenceVariable,
            TupleVariable,
        ),
    )
