import Foundation

enum AppError: Error {
    case UserLogin
    case UserRegister
    case BriefOrderRetrieve
    case OrderRetrieve
    case BillRetreive
    case PlaceOrder
    case MechanicsForManagerRetrieve
    case UnmanagedOrderRetrieve
    case DenyOrder
    case ConfirmOrder
    case AddBillItem
    case BillTheBill
    case PayBill
    case OrderUpdateNotes
}
