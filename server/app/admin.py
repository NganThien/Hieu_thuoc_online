# -*- coding: utf-8 -*-
"""
Flask-Admin: Cấu hình trang quản trị cho Nhà thuốc.
"""
import os
from flask import current_app
from flask_admin import Admin
from flask_admin.contrib.sqla import ModelView
from flask_admin.form.upload import ImageUploadField
from . import db
from .models import User, Product, Order, OrderDetail, Category


def _upload_path():
    """Đường dẫn thư mục upload ảnh (trong static)."""
    base = current_app.static_folder or 'static'
    path = os.path.join(base, 'uploads', 'products')
    os.makedirs(path, exist_ok=True)
    return path


def _image_url_relative():
    """Đường dẫn tương đối cho URL ảnh (uploads/products/)."""
    return 'uploads/products/'


# --- User ---
class UserAdminView(ModelView):
    column_list = ['id', 'phone', 'full_name', 'role', 'address', 'created_at']
    column_searchable_list = ['phone', 'full_name']
    column_filters = ['role']
    column_editable_list = ['full_name', 'role', 'address']
    form_columns = ['phone', 'password', 'full_name', 'role', 'address']
    form_excluded_columns = ['created_at']


# --- Category ---
class CategoryAdminView(ModelView):
    column_list = ['id', 'name']
    column_searchable_list = ['name']
    form_columns = ['name']


# --- Product: upload ảnh, tìm kiếm theo tên, lọc theo giá ---
class ProductAdminView(ModelView):
    column_list = ['id', 'name', 'price', 'category_id', 'image_url', 'description']
    column_searchable_list = ['name', 'description']
    column_filters = ['price', 'category_id']
    column_sortable_list = ['id', 'name', 'price', 'category_id']
    column_editable_list = ['name', 'price']
    form_columns = ['name', 'price', 'description', 'image_url', 'category_id']

    # Upload ảnh: lưu vào static/uploads/products/
    form_overrides = {'image_url': ImageUploadField}
    form_args = {
        'image_url': {
            'label': 'Ảnh sản phẩm',
            'base_path': lambda: _upload_path(),
            'relative_path': lambda: _image_url_relative(),
            'allowed_extensions': ('jpg', 'jpeg', 'png', 'gif', 'webp'),
        }
    }


# --- Order: danh sách đơn hàng, sửa status ---
class OrderAdminView(ModelView):
    column_list = ['id', 'user_id', 'total_amount', 'status', 'shipping_address', 'created_at']
    column_searchable_list = ['shipping_address']
    column_filters = ['status', 'created_at']
    column_editable_list = ['status']
    column_sortable_list = ['id', 'total_amount', 'status', 'created_at']
    form_columns = ['user_id', 'total_amount', 'status', 'shipping_address']
    form_args = {
        'status': {
            'choices': [
                ('pending', 'Chờ xử lý'),
                ('shipping', 'Đang giao'),
                ('completed', 'Hoàn thành'),
                ('cancelled', 'Đã hủy'),
            ]
        }
    }


# --- OrderDetail ---
class OrderDetailAdminView(ModelView):
    column_list = ['id', 'order_id', 'product_id', 'quantity', 'price_at_purchase']
    column_filters = ['order_id', 'product_id']
    form_columns = ['order_id', 'product_id', 'quantity', 'price_at_purchase']


def init_admin(app):
    """Khởi tạo Flask-Admin và đăng ký các view."""
    # Flask-Admin 2.x dùng theme= (mặc định Bootstrap4), không còn template_mode
    admin = Admin(app, name='Quản lý Nhà thuốc')

    admin.add_view(UserAdminView(User, db.session, name='Người dùng', category='Hệ thống'))
    admin.add_view(CategoryAdminView(Category, db.session, name='Danh mục', category='Sản phẩm'))
    admin.add_view(ProductAdminView(Product, db.session, name='Sản phẩm', category='Sản phẩm'))
    admin.add_view(OrderAdminView(Order, db.session, name='Đơn hàng', category='Đơn hàng'))
    admin.add_view(OrderDetailAdminView(OrderDetail, db.session, name='Chi tiết đơn', category='Đơn hàng'))

    return admin
