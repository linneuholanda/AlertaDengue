from django.conf.urls import patterns, include, url
from django.contrib import admin
from dados.views import HomePageView

admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'AlertaDengue.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),
    url(r'^$', HomePageView.as_view(), name='home'),
    url(r'^admin/', include(admin.site.urls)),
)
