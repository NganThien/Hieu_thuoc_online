"""add category image_url

Revision ID: b92e2c1
Revises: a81d1c0d5f4d
Create Date: 2026-02-15

"""
from alembic import op
import sqlalchemy as sa

revision = 'b92e2c1'
down_revision = 'a81d1c0d5f4d'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('categories', sa.Column('image_url', sa.Text(), nullable=True))


def downgrade():
    op.drop_column('categories', 'image_url')
