#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class TimelinesController < ApplicationController
  unloadable
  helper :timelines

  before_filter :disable_api
  before_filter :find_project_by_project_id
  before_filter :authorize

  def index
    @timeline = @project.timelines.first
    if @timeline.nil?
      redirect_to new_project_timeline_path(@project)
    else
      redirect_to project_timeline_path(@project, @timeline)
    end
  end

  def show
    @visible_timelines = @project.timelines.all
    push_visible_timeline_paths

    @timeline = @project.timelines.find(params[:id])
    gon.current_timeline_id = @timeline.id
    push_timeline_options

    push_timeline_translations
  end

  def new
    @timeline = @project.timelines.build
  end

  def create
    remove_blank_options

    @timeline = @project.timelines.build(params[:timeline])

    if @timeline.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_timeline_path(@project, @timeline)
    else
      render :action => "new"
    end
  end

  def edit
    @timeline = @project.timelines.find(params[:id])
  end

  def update
    @timeline = @project.timelines.find(params[:id])

    if @timeline.update_attributes(params[:timeline])
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_timeline_path(@project, @timeline)
    else
      render :action => "edit"
    end
  end

  def confirm_destroy
    @timeline = @project.timelines.find(params[:id])
  end

  def destroy
    @timeline = @project.timelines.find(params[:id])
    @timeline.destroy

    flash[:notice] = l(:notice_successful_delete)
    redirect_to project_timelines_path @project
  end

  protected

  def default_breadcrumb
    l('timelines.project_menu.timelines')
  end

  def remove_blank_options
    options = params[:timeline][:options] || {}

    options.each do |k, v|
      options[k] = v.reject(&:blank?) if v.is_a? Array
    end

    params[:timeline][:options] = options
  end

  def visible_timeline_paths
    @visible_timelines.inject({}) do |timeline_paths, timeline|
      timeline_paths.merge(timeline.id => {path: project_timeline_path(@project, timeline)})
    end

  end

  def push_visible_timeline_paths
    gon.timelines = visible_timeline_paths
  end

  def push_timeline_options
    gon.timeline_options = @timeline.options.reverse_merge(
      project_id: @timeline.project.identifier,
      url_prefix: Redmine::Utils.relative_url_root || ''
    )
  end

  def push_timeline_translations
    props = ['label_no_data',
             'timelines.change',
             'timelines.errors.report_epicfail',
             'timelines.errors.report_timeout',
             'timelines.errors.not_implemented',
             'timelines.errors.report_comparison',
             'timelines.empty',
             'timelines.filter.noneSelection',
             'timelines.filter.column.due_date',
             'timelines.filter.column.name',
             'timelines.filter.column.type',
             'timelines.filter.column.status',
             'timelines.filter.column.responsible',
             'timelines.filter.column.start_date',
             'timelines.filter.column.assigned_to',
             'timelines.filter.grouping_other',
             'timelines.outline',
             'timelines.outlines.aggregation',
             'timelines.outlines.level1',
             'timelines.outlines.level2',
             'timelines.outlines.level3',
             'timelines.outlines.level4',
             'timelines.outlines.level5',
             'timelines.outlines.all',
             'timelines.zoom.in',
             'timelines.zoom.out',
             'timelines.zoom.days',
             'timelines.zoom.weeks',
             'timelines.new_work_package',
             'timelines.zoom.months',
             'timelines.zoom.quarters',
             'timelines.zoom.years']
    gon.timeline_translations = props.inject({}) do |translations, key|
      translations.merge(key => l(key))
    end
  end
end