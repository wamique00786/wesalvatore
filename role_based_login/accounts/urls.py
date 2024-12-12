from django.urls import path
from .views import signup_view, login_view, logout_view, admin_dashboard, volunteer_dashboard, user_dashboard, access_denied, picture_sent_successfully
from . import views

urlpatterns = [
    path('signup/', signup_view, name='signup'),
    path('login/', login_view, name='login'),
    path('logout/', logout_view, name='logout'),
    path('admin-dashboard/', admin_dashboard, name='admin_dashboard'),
    path('volunteer-dashboard/', volunteer_dashboard, name='volunteer_dashboard'),
    path('user-dashboard/', views.user_dashboard, name='user_dashboard'),
    path('access-denied/', access_denied, name='access_denied'),
    path('picture-sent-successfully/', views.picture_sent_successfully, name='picture_sent_successfully'),
    path('manage-volunteers/', views.manage_volunteers, name='manage_volunteers'),
    path('assign-batch/', views.assign_batch, name='assign_batch'),
    path('manage-users/', views.manage_users, name='manage_users'),
    path('mark-task-completed/<int:task_id>/', views.mark_task_completed, name='mark_task_completed'),
    path('assign-task/', views.assign_task, name='assign_task'),
    path('assign-volunteer/<int:user_id>/', views.assign_volunteer, name='assign_volunteer'),
    path('get-nearest-volunteers/', views.get_nearest_volunteers, name='get_nearest_volunteers'),
    path('submit-image/', views.submit_image, name='submit_image'),
]

