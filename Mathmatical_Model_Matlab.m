clc; clear; close all;
% Licensed under the MIT License.
% Part of the Decision-Support Tool (DST) for WWTP Retrofitting.
% -------------------------------------------------------------------------
%  EGYPTIAN CODE LIMITS (Grade A) & WQI WEIGHTS
% -------------------------------------------------------------------------
S = [10; 10; 50; 8.5; 1000];          % [BOD5, TSS, COD, pH, Coliform]
w = [0.30; 0.25; 0.20; 0.10; 0.15];

% -------------------------------------------------------------------------
%  STATION 1 — ZENIN
% -------------------------------------------------------------------------
ST(1).Name    = 'ZENIN WWTP';
ST(1).Q       = 404967;
ST(1).Cin     = [131; 135; 307];
ST(1).P       = [15.7; 15.0; 42.5; 7.43; 707625];
ST(1).SEC     = 0.45;
ST(1).Biogas  = 150000;
ST(1).BG_ref  = 328860;

% -------------------------------------------------------------------------
%  STATION 2 — ABU RAWASH
% -------------------------------------------------------------------------
ST(2).Name    = 'ABU RAWASH WWTP';
ST(2).Q       = 800000;
ST(2).Cin     = [400; 500; 600];
ST(2).P       = [400*0.60; 500*0.35; 600*0.60; 7.2; 1e7];
ST(2).SEC     = (24.35e6 * 0.9 * 24) / 800000 / 1000;
ST(2).Biogas  = 328860;
ST(2).BG_ref  = 328860;

% -------------------------------------------------------------------------
%  MAIN LOOP
% -------------------------------------------------------------------------
for k = 1:2
    % --- Derived values ---
    q       = (ST(k).P ./ S) .* 100;
    WQI     = w' * q;
    flags   = (ST(k).P - S) > max(0.05.*S, 0.1);

    k_bio = 0.5;
    V_reactor = 0;
    if flags(1)
        HRT = (1/k_bio) * log(ST(k).Cin(1) / S(1));
        V_reactor = (ST(k).Q / 24) * HRT;
    end
    D_UV = 0;
    if flags(5)
        D_UV = -log(S(5) / ST(k).P(5)) / 0.22;
    end
    Energy_MWh = ST(k).Biogas * (768 / ST(k).BG_ref);

    render_dashboard_v11(ST(k), S, WQI, flags, V_reactor, D_UV, Energy_MWh, k);
end


% =========================================================================
function render_dashboard_v11(ST, S, WQI, ~, V_reactor, D_UV, Energy_MWh, fnum)

% ---- PALETTE (Modern Dark Theme) ----
C.bg       = [0.06  0.07  0.10];
C.panel    = [0.10  0.12  0.16];
C.card     = [0.14  0.16  0.21];
C.border   = [0.25  0.28  0.36];
C.txt1     = [0.94  0.96  0.98];
C.txt2     = [0.60  0.65  0.75];
C.red      = [0.95  0.35  0.35];
C.green    = [0.25  0.85  0.65];
C.blue     = [0.30  0.68  0.98];
C.amber    = [0.98  0.75  0.20];
C.violet   = [0.68  0.55  0.98];
C.teal     = [0.20  0.80  0.80];
C.track    = [0.22  0.25  0.32];

FN = 'Segoe UI';

% ---- FIGURE ----
fig = figure('Name', sprintf('DST Pro — %s', ST.Name), ...
  'Position', [50+fnum*40, 50+fnum*30, 1200, 700], ...
    'Color', C.bg, 'NumberTitle', 'off', 'InvertHardcopy', 'off', ...
    'MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off');

% =========================================================================
ax_hdr = axes('Parent', fig, 'Units', 'normalized', ...
    'Position', [0 0.93 1 0.07], 'Color', C.panel, 'Visible', 'off');
hold(ax_hdr,'on');
xlim(ax_hdr,[0 1]); ylim(ax_hdr,[0 1]);
fill(ax_hdr,[0 1 1 0],[0 0 1 1], C.panel, 'EdgeColor','none');
fill(ax_hdr,[0 1 1 0],[0 0 0.06 0.06], C.violet, 'EdgeColor','none');

text(ax_hdr,0.5, 0.70, sprintf('DST PRO  ·  %s  ·  GRADE A COMPLIANCE ANALYSIS', ST.Name), ...
    'FontName',FN,'FontSize',18,'FontWeight','bold','Color',C.txt1, ...
    'HorizontalAlignment','center');
text(ax_hdr,0.5, 0.30, sprintf('Flow: %s m³/day   |   SEC Baseline: %.4f kWh/m³', ...
    num2sepstr(ST.Q), ST.SEC), ...
    'FontName',FN,'FontSize',13,'Color',C.txt2,'HorizontalAlignment','center');

% =========================================================================
%  ROW 1: 5 PARAMETER GAUGES (larger fonts as before)
% =========================================================================
gauge_params = {'BOD_5','TSS','COD','pH','Coliform'};
gauge_vals   = ST.P;
gauge_lims   = S;
gauge_units  = {'mg/L','mg/L','mg/L','—','CFU/100mL'};
gauge_max    = [500, 600, 700, 14, 1.2e7];

n_g = 5;
gw  = 0.16;
gh  = 0.40;
gy  = 0.51;
gx_start = 0.03;
gx_gap   = (1 - 2*gx_start - n_g*gw) / (n_g-1);

for i = 1:n_g
    gx = gx_start + (i-1)*(gw + gx_gap);
    ax = axes('Parent',fig,'Units','normalized', ...
        'Position',[gx gy gw gh], ...
        'Color',C.card,'Visible','off', ...
        'XColor','none','YColor','none');
    hold(ax,'on');
    axis(ax,'equal','off');
    xlim(ax,[-1.3 1.3]); ylim(ax,[-1.1 1.3]);

    val   = gauge_vals(i);
    lim   = gauge_lims(i);
    gmx   = gauge_max(i);
    frac  = min(val / gmx, 1.0);
    flim  = min(lim / gmx, 1.0);
    pass  = (val <= lim * 1.05);

    ring_clr = C.green;
    if ~pass, ring_clr = C.red; end

    draw_rounded_rect(ax, [-1.25 -1.05], 2.50, 2.30, 0.12, C.card, C.border, 1.5);
    draw_arc(ax, 0, 0, 0.90, pi, 0, 60, C.track, 22);
    ang_end = pi - frac * pi;
    draw_arc(ax, 0, 0, 0.90, pi, ang_end, 60, ring_clr, 22);
    ang_lim = pi - flim * pi;
    lx = [0.72*cos(ang_lim), 1.08*cos(ang_lim)];
    ly = [0.72*sin(ang_lim), 1.08*sin(ang_lim)];
    plot(ax, lx, ly, 'Color', C.amber, 'LineWidth', 3);

    if val >= 1e6
        exp_v = floor(log10(val));
        man_v = val / 10^exp_v;
        vstr  = sprintf('%.1f', man_v);
        estr  = sprintf('×10^{%d}', exp_v);
        text(ax, 0, 0.12, vstr, 'FontName',FN,'FontSize',20,'FontWeight','bold', ...
            'Color',C.txt1,'HorizontalAlignment','center');
        text(ax, 0, -0.22, estr, 'FontName',FN,'FontSize',11,'Color',C.txt2, ...
            'HorizontalAlignment','center','Interpreter','tex');
    else
        text(ax, 0, 0.08, sprintf('%.1f', val), 'FontName',FN,'FontSize',22, ...
            'FontWeight','bold','Color',C.txt1,'HorizontalAlignment','center');
    end

    text(ax, 0, -0.42, sprintf('Limit: %g %s', lim, gauge_units{i}), ...
        'FontName',FN,'FontSize',10,'Color',C.amber,'HorizontalAlignment','center');
    text(ax, 0, -0.68, gauge_params{i}, 'FontName',FN,'FontSize',13, ...
        'FontWeight','bold','Color',C.txt1,'HorizontalAlignment','center','Interpreter','tex');

    if pass
        badge_clr = C.green; badge_txt = '  PASS ✓';
    else
        badge_clr = C.red;   badge_txt = '  FAIL ✗';
    end
    text(ax, 0, -0.90, badge_txt, 'FontName',FN,'FontSize',12, ...
        'FontWeight','bold','Color',badge_clr,'HorizontalAlignment','center');

    text(ax,-1.08,-0.08,'0','FontName',FN,'FontSize',9,'Color',C.txt2,'HorizontalAlignment','center');
    if gmx >= 1e6
        text(ax,1.08,-0.08,sprintf('%.0emax',gmx),'FontName',FN,'FontSize',9, ...
            'Color',C.txt2,'HorizontalAlignment','center');
    else
        text(ax,1.08,-0.08,num2str(gmx,'%.0f'),'FontName',FN,'FontSize',9, ...
            'Color',C.txt2,'HorizontalAlignment','center');
    end
end

% =========================================================================
%  ROW 2 — FULL-WIDTH ECONOMICS & ACTIONABLE DECISIONS (with 3 cards)
% =========================================================================
ax_eco = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.03 0.06 0.94 0.40], ...
    'Color',C.card,'Visible','off');
hold(ax_eco,'on');
xlim(ax_eco,[0 1]); ylim(ax_eco,[0 1]);
draw_rounded_rect(ax_eco,[0 0],1,1,0.03,C.card,C.border,1.5);

% ---- THREE ECONOMIC KPI CARDS (side by side) ----
% Card 1: Energy Recovery (left)
draw_kpi_card(ax_eco, 0.03, 0.62, 0.30, 0.33, ...
    'ENERGY RECOVERY', sprintf('%.0f MWh/day', Energy_MWh), C.green, C.card, C.border, C.txt2, FN, 11, 14);
% Card 2: SEC Baseline (middle)
draw_kpi_card(ax_eco, 0.35, 0.62, 0.30, 0.33, ...
    'SEC BASELINE', sprintf('%.4f kWh/m³', ST.SEC), C.amber, C.card, C.border, C.txt2, FN, 11, 14);
% Card 3: WQI Score (right)
% Determine color and status based on WQI
if WQI > 100
    wqi_color = C.red;
    wqi_status = 'NON-COMPLIANT';
else
    wqi_color = C.green;
    wqi_status = 'COMPLIANT';
end
draw_kpi_card(ax_eco, 0.67, 0.62, 0.30, 0.33, ...
    'WQI SCORE', sprintf('%.1f', WQI), wqi_color, C.card, C.border, C.txt2, FN, 11, 16);
ax_wqi_card = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.67+0.03 0.62 0.30-0.03 0.33], 'Visible','off'); % approximate
wqi_x = 0.67; wqi_y = 0.62; wqi_w = 0.30; wqi_h = 0.33;
bg_light = [C.card(1)+0.04, C.card(2)+0.04, C.card(3)+0.06];
draw_rounded_rect(ax_eco, [wqi_x wqi_y], wqi_w, wqi_h, 0.08, bg_light, C.border, 1.2);
text(ax_eco, wqi_x+wqi_w/2, wqi_y+wqi_h*0.72, 'WQI SCORE', 'FontName',FN,'FontSize',11, ...
    'Color',C.txt2,'HorizontalAlignment','center','FontWeight','bold');
text(ax_eco, wqi_x+wqi_w/2, wqi_y+wqi_h*0.40, sprintf('%.1f', WQI), 'FontName',FN,'FontSize',18, ...
    'Color',wqi_color,'HorizontalAlignment','center','FontWeight','bold');
text(ax_eco, wqi_x+wqi_w/2, wqi_y+wqi_h*0.15, wqi_status, 'FontName',FN,'FontSize',9, ...
    'Color',wqi_color,'HorizontalAlignment','center','FontWeight','bold');

% ---- DIVIDER ----
line(ax_eco,[0.03 0.97],[0.57 0.57],'Color',C.border,'LineWidth',1.2);

% ---- ENHANCED DECISIONS SECTION ----
text(ax_eco,0.05,0.52,'REQUIRED UPGRADES & SOLUTIONS','FontName',FN,'FontSize',14, ...
    'FontWeight','bold','Color',C.violet);

y_positions = [0.42, 0.30, 0.18];

% UV Disinfection
if D_UV > 0
    draw_upgrade_fixed(ax_eco, y_positions(1), '⚡', 'UV Disinfection', ...
        sprintf('Dose: %.1f mJ/cm²', D_UV), 'Install medium-pressure UV reactor', 'High', '$0.18/m³', C, FN, false, 12, 10.5);
else
    draw_upgrade_fixed(ax_eco, y_positions(1), '✓', 'UV Disinfection', 'Compliant', 'No action needed', 'None', '—', C, FN, true, 12, 10.5);
end

% Bio-Reactor
if V_reactor > 0
    draw_upgrade_fixed(ax_eco, y_positions(2), '🏭', 'Biological Reactor', ...
        sprintf('Volume: %.2e m³', V_reactor), 'Construct activated sludge tank', 'Critical', '$2.4M', C, FN, false, 12, 10.5);
else
    draw_upgrade_fixed(ax_eco, y_positions(2), '✓', 'Biological Reactor', 'Compliant', 'No action needed', 'None', '—', C, FN, true, 12, 10.5);
end

% Pathogen Control
if ST.P(5) > S(5)
    draw_upgrade_fixed(ax_eco, y_positions(3), '🦠', 'Pathogen Control', ...
        sprintf('Current: %.1e CFU/100mL', ST.P(5)), 'Install chlorination + dechlorination', 'High', '$0.09/m³', C, FN, false, 12, 10.5);
else
    draw_upgrade_fixed(ax_eco, y_positions(3), '✓', 'Pathogen Control', 'Compliant', 'No action needed', 'None', '—', C, FN, true, 12, 10.5);
end

% Summary note
text(ax_eco,0.03,0.07,'* Estimated costs based on similar regional projects. Final costs subject to site survey.', ...
    'FontName',FN,'FontSize',9,'Color',C.txt2,'FontAngle','italic');

title(ax_eco,'ECONOMICS & ACTIONABLE DECISIONS','FontName',FN,'FontSize',15, ...
    'FontWeight','bold','Color',C.txt1);

end

% =========================================================================

function draw_arc(ax, cx, cy, r, ang_start, ang_end, n, clr, lw)
    theta = linspace(ang_start, ang_end, n);
    plot(ax, cx + r*cos(theta), cy + r*sin(theta), 'Color', clr, 'LineWidth', lw);
end

function draw_rounded_rect(ax, origin, w, h, curv, fc, ec, lw)
    rectangle(ax, 'Position', [origin(1), origin(2), w, h], ...
        'Curvature', curv, 'FaceColor', fc, 'EdgeColor', ec, 'LineWidth', lw);
end

function draw_kpi_card(ax, x, y, w, h, label, value, vclr, bg, border, lbl_clr, FN, label_fs, value_fs)
    bg_light = [bg(1)+0.04, bg(2)+0.04, bg(3)+0.06];
    draw_rounded_rect(ax, [x y], w, h, 0.08, bg_light, border, 1.2);
    text(ax, x+w/2, y+h*0.72, label, 'FontName',FN,'FontSize',label_fs, ...
        'Color',lbl_clr,'HorizontalAlignment','center','FontWeight','bold');
    text(ax, x+w/2, y+h*0.30, value, 'FontName',FN,'FontSize',value_fs, ...
        'Color',vclr,'HorizontalAlignment','center','FontWeight','bold');
end

function draw_upgrade_fixed(ax, y, icon, label, detail, action, priority, cost, C, FN, isCompliant, icon_fs, text_fs)
    bg_clr = [C.card(1)+0.05, C.card(2)+0.05, C.card(3)+0.05];
    draw_rounded_rect(ax, [0.03 y-0.045], 0.94, 0.09, 0.05, bg_clr, C.border, 0.8);
    
    if isCompliant
        icon_color = C.green;
        priority_color = C.green;
        priority_text = 'Compliant';
    else
        icon_color = C.red;
        if strcmp(priority,'Critical')
            priority_color = C.red;
        else
            priority_color = C.amber;
        end
        priority_text = priority;
    end
    
    text(ax, 0.05, y, icon, 'FontName',FN,'FontSize',icon_fs+2,'Color',icon_color);
    text(ax, 0.12, y, label, 'FontName',FN,'FontSize',text_fs+1,'FontWeight','bold','Color',C.txt1);
    text(ax, 0.32, y, detail, 'FontName',FN,'FontSize',text_fs,'Color',C.txt2);
    text(ax, 0.58, y, action, 'FontName',FN,'FontSize',text_fs,'Color',C.amber,'FontWeight','bold');
    text(ax, 0.85, y, priority_text, 'FontName',FN,'FontSize',text_fs-1, ...
        'Color',priority_color,'FontWeight','bold');
    if ~isCompliant && ~strcmp(cost,'—')
        text(ax, 0.94, y-0.022, cost, 'FontName',FN,'FontSize',text_fs-2,'Color',C.txt2,'HorizontalAlignment','right');
    end
end

function s = num2sepstr(n)
    s = num2str(n);
    if n >= 1000
        s = regexprep(s, '(\d)(?=(\d{3})+(?!\d))', '$1,');
    end
end