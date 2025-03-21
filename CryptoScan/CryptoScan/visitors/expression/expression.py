import logging
from functools import lru_cache

from CryptoScan.core.expressions.assignment_operation import AssignmentOperation
from CryptoScan.core.expressions.binary_operation import BinaryOperation
from CryptoScan.core.expressions.call_expression import CallExpression
from CryptoScan.core.expressions.conditional_expression import ConditionalExpression
from CryptoScan.core.expressions.elementary_type_name_expression import ElementaryTypeNameExpression
from CryptoScan.core.expressions.expression import Expression
from CryptoScan.core.expressions.identifier import Identifier
from CryptoScan.core.expressions.index_access import IndexAccess
from CryptoScan.core.expressions.literal import Literal
from CryptoScan.core.expressions.member_access import MemberAccess
from CryptoScan.core.expressions.new_array import NewArray
from CryptoScan.core.expressions.new_contract import NewContract
from CryptoScan.core.expressions.new_elementary_type import NewElementaryType
from CryptoScan.core.expressions.tuple_expression import TupleExpression
from CryptoScan.core.expressions.type_conversion import TypeConversion
from CryptoScan.core.expressions.unary_operation import UnaryOperation
from CryptoScan.core.expressions.super_call_expression import SuperCallExpression
from CryptoScan.core.expressions.super_identifier import SuperIdentifier
from CryptoScan.core.expressions.self_identifier import SelfIdentifier
from CryptoScan.exceptions import SlitherError

logger = logging.getLogger("ExpressionVisitor")


@lru_cache()
def get_visitor_mapping():
    """Returns a visitor mapping from expression type to visiting functions."""
    return {
        AssignmentOperation: "_visit_assignement_operation",
        BinaryOperation: "_visit_binary_operation",
        CallExpression: "_visit_call_expression",
        ConditionalExpression: "_visit_conditional_expression",
        ElementaryTypeNameExpression: "_visit_elementary_type_name_expression",
        Identifier: "_visit_identifier",
        IndexAccess: "_visit_index_access",
        Literal: "_visit_literal",
        MemberAccess: "_visit_member_access",
        NewArray: "_visit_new_array",
        NewContract: "_visit_new_contract",
        NewElementaryType: "_visit_new_elementary_type",
        TupleExpression: "_visit_tuple_expression",
        TypeConversion: "_visit_type_conversion",
        UnaryOperation: "_visit_unary_operation",
        SelfIdentifier: "_visit_identifier",
        SuperIdentifier: "_visit_identifier",
        SuperCallExpression: "_visit_call_expression",
    }


# pylint: disable=too-few-public-methods
class ExpressionVisitor:
    def __init__(self, expression: Expression) -> None:
        super().__init__()
        # Inherited class must declare their variables prior calling super().__init__
        self._expression = expression
        self._visit_expression(self.expression)

    @property
    def expression(self) -> Expression:
        return self._expression

    # visit an expression
    # call pre_visit, visit_expression_name, post_visit
    def _visit_expression(self, expression: Expression) -> None:
        self._pre_visit(expression)

        if expression is not None:
            visitor_method = get_visitor_mapping().get(expression.__class__)
            if not visitor_method:
                raise SlitherError(f"Expression not handled: {expression}")

            visitor = getattr(self, visitor_method)
            visitor(expression)

        self._post_visit(expression)

    # visit_expression_name

    def _visit_assignement_operation(self, expression: AssignmentOperation) -> None:
        self._visit_expression(expression.expression_left)
        self._visit_expression(expression.expression_right)

    def _visit_binary_operation(self, expression: BinaryOperation) -> None:
        self._visit_expression(expression.expression_left)
        self._visit_expression(expression.expression_right)

    def _visit_call_expression(self, expression: CallExpression) -> None:
        self._visit_expression(expression.called)
        for arg in expression.arguments:
            if arg:
                self._visit_expression(arg)
        if expression.call_value:
            self._visit_expression(expression.call_value)
        if expression.call_gas:
            self._visit_expression(expression.call_gas)
        if expression.call_salt:
            self._visit_expression(expression.call_salt)

    def _visit_conditional_expression(self, expression: ConditionalExpression) -> None:
        self._visit_expression(expression.if_expression)
        self._visit_expression(expression.else_expression)
        self._visit_expression(expression.then_expression)

    def _visit_elementary_type_name_expression(
        self, expression: ElementaryTypeNameExpression
    ) -> None:
        pass

    def _visit_identifier(self, expression: Identifier) -> None:
        pass

    def _visit_index_access(self, expression: IndexAccess) -> None:
        self._visit_expression(expression.expression_left)
        self._visit_expression(expression.expression_right)

    def _visit_literal(self, expression: Literal) -> None:
        pass

    def _visit_member_access(self, expression: MemberAccess) -> None:
        self._visit_expression(expression.expression)

    def _visit_new_array(self, expression: NewArray) -> None:
        pass

    def _visit_new_contract(self, expression: NewContract) -> None:
        pass

    def _visit_new_elementary_type(self, expression: NewElementaryType) -> None:
        pass

    def _visit_tuple_expression(self, expression: TupleExpression) -> None:
        for e in expression.expressions:
            if e:
                self._visit_expression(e)

    def _visit_type_conversion(self, expression: TypeConversion) -> None:
        self._visit_expression(expression.expression)

    def _visit_unary_operation(self, expression: UnaryOperation) -> None:
        self._visit_expression(expression.expression)

    # pre visit

    def _pre_visit(self, expression: Expression) -> None:  # pylint: disable=too-many-branches
        if isinstance(expression, AssignmentOperation):
            self._pre_assignement_operation(expression)

        elif isinstance(expression, BinaryOperation):
            self._pre_binary_operation(expression)

        elif isinstance(expression, CallExpression):
            self._pre_call_expression(expression)

        elif isinstance(expression, ConditionalExpression):
            self._pre_conditional_expression(expression)

        elif isinstance(expression, ElementaryTypeNameExpression):
            self._pre_elementary_type_name_expression(expression)

        elif isinstance(expression, Identifier):
            self._pre_identifier(expression)

        elif isinstance(expression, IndexAccess):
            self._pre_index_access(expression)

        elif isinstance(expression, Literal):
            self._pre_literal(expression)

        elif isinstance(expression, MemberAccess):
            self._pre_member_access(expression)

        elif isinstance(expression, NewArray):
            self._pre_new_array(expression)

        elif isinstance(expression, NewContract):
            self._pre_new_contract(expression)

        elif isinstance(expression, NewElementaryType):
            self._pre_new_elementary_type(expression)

        elif isinstance(expression, TupleExpression):
            self._pre_tuple_expression(expression)

        elif isinstance(expression, TypeConversion):
            self._pre_type_conversion(expression)

        elif isinstance(expression, UnaryOperation):
            self._pre_unary_operation(expression)

        elif expression is None:
            pass

        else:
            raise SlitherError(f"Expression not handled: {expression}")

    # pre_expression_name

    def _pre_assignement_operation(self, expression: AssignmentOperation) -> None:
        pass

    def _pre_binary_operation(self, expression: BinaryOperation) -> None:
        pass

    def _pre_call_expression(self, expression: CallExpression) -> None:
        pass

    def _pre_conditional_expression(self, expression: ConditionalExpression) -> None:
        pass

    def _pre_elementary_type_name_expression(
        self, expression: ElementaryTypeNameExpression
    ) -> None:
        pass

    def _pre_identifier(self, expression: Identifier) -> None:
        pass

    def _pre_index_access(self, expression: IndexAccess) -> None:
        pass

    def _pre_literal(self, expression: Literal) -> None:
        pass

    def _pre_member_access(self, expression: MemberAccess) -> None:
        pass

    def _pre_new_array(self, expression: NewArray) -> None:
        pass

    def _pre_new_contract(self, expression: NewContract) -> None:
        pass

    def _pre_new_elementary_type(self, expression: NewElementaryType) -> None:
        pass

    def _pre_tuple_expression(self, expression: TupleExpression) -> None:
        pass

    def _pre_type_conversion(self, expression: TypeConversion) -> None:
        pass

    def _pre_unary_operation(self, expression: UnaryOperation) -> None:
        pass

    # post visit

    def _post_visit(self, expression: Expression) -> None:  # pylint: disable=too-many-branches
        if isinstance(expression, AssignmentOperation):
            self._post_assignement_operation(expression)

        elif isinstance(expression, BinaryOperation):
            self._post_binary_operation(expression)

        elif isinstance(expression, CallExpression):
            self._post_call_expression(expression)

        elif isinstance(expression, ConditionalExpression):
            self._post_conditional_expression(expression)

        elif isinstance(expression, ElementaryTypeNameExpression):
            self._post_elementary_type_name_expression(expression)

        elif isinstance(expression, Identifier):
            self._post_identifier(expression)

        elif isinstance(expression, IndexAccess):
            self._post_index_access(expression)

        elif isinstance(expression, Literal):
            self._post_literal(expression)

        elif isinstance(expression, MemberAccess):
            self._post_member_access(expression)

        elif isinstance(expression, NewArray):
            self._post_new_array(expression)

        elif isinstance(expression, NewContract):
            self._post_new_contract(expression)

        elif isinstance(expression, NewElementaryType):
            self._post_new_elementary_type(expression)

        elif isinstance(expression, TupleExpression):
            self._post_tuple_expression(expression)

        elif isinstance(expression, TypeConversion):
            self._post_type_conversion(expression)

        elif isinstance(expression, UnaryOperation):
            self._post_unary_operation(expression)

        elif expression is None:
            pass

        else:
            raise SlitherError(f"Expression not handled: {expression}")

    # post_expression_name

    def _post_assignement_operation(self, expression: AssignmentOperation) -> None:
        pass

    def _post_binary_operation(self, expression: BinaryOperation) -> None:
        pass

    def _post_call_expression(self, expression: CallExpression) -> None:
        pass

    def _post_conditional_expression(self, expression: ConditionalExpression) -> None:
        pass

    def _post_elementary_type_name_expression(
        self, expression: ElementaryTypeNameExpression
    ) -> None:
        pass

    def _post_identifier(self, expression: Identifier) -> None:
        pass

    def _post_index_access(self, expression: IndexAccess) -> None:
        pass

    def _post_literal(self, expression: Literal) -> None:
        pass

    def _post_member_access(self, expression: MemberAccess) -> None:
        pass

    def _post_new_array(self, expression: NewArray) -> None:
        pass

    def _post_new_contract(self, expression: NewContract) -> None:
        pass

    def _post_new_elementary_type(self, expression: NewElementaryType) -> None:
        pass

    def _post_tuple_expression(self, expression: TupleExpression) -> None:
        pass

    def _post_type_conversion(self, expression: TypeConversion) -> None:
        pass

    def _post_unary_operation(self, expression: UnaryOperation) -> None:
        pass
